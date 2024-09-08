//
//  GameChatViewModel.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 27/11/2021.
//

import Foundation
import RxSwift
import RxRelay

protocol GameChatViewModelInput {
    func viewDidLoad()
    func sendNewMessage(message: String)
    func loadMoreMessages()
    func didTapLeftButtonOnSystemMsg()
    func didTapRightButtonOnSystemMsg()
    func userTypingAction(isTyping: Bool)
}

protocol GameChatViewModelOutput {
    var currentSender: ChatUserMessage.ChatUser { get }
    var messagesLoaded: BehaviorRelay<[ChatMessage]> { get }
    var newMessageReceived: PublishSubject<ChatMessage> { get }
    var updateNewMessageSended: PublishSubject<[ChatMessage]> { get }
    var didLoadMoreMessages: PublishSubject<[ChatMessage]> { get }
    var updateChatSystemMessage: PublishSubject<ChatSystemMessageState> { get }
    var isTyping: PublishSubject<Bool> { get }
}

enum ChatSystemMessageState {
    case insertion(Int, ChatMessage)
    case deletion(Int)
}

protocol GameChatViewModel: GameChatViewModelInput, GameChatViewModelOutput {}

class DefaultGameChatViewModel: GameChatViewModel {
    
    private let gameID: String
    private let gameStatusUseCase: GameStatusUseCase
    private let fetchGameDetailUseCase: FetchGameDetailUseCase
    private let fetchMessagesUseCase: FetchMessagesUseCase
    private let gameRoundPostUseCase: GameRoundPostUseCase
    private let postMessageUseCase: PostMessageUseCase
    private let userTypingMsgUseCase: UserTypingMessageUseCase
    private let fetchMoreMsgsUseCase: FetchMoreMessagesUseCase
    
    private var currentGame: Game?
    private var messages: [ChatMessage] = []
    
    private static let LIMIT_PER_PAGE: Int = 8
    private var currentPage: Int = 0
    
    // MARK: - Output
    let currentSender: ChatUserMessage.ChatUser
    var messagesLoaded = BehaviorRelay<[ChatMessage]>(value: [])
    let newMessageReceived = PublishSubject<ChatMessage>()
    let updateNewMessageSended = PublishSubject<[ChatMessage]>()
    let didLoadMoreMessages = PublishSubject<[ChatMessage]>()
    let updateChatSystemMessage = PublishSubject<ChatSystemMessageState>()
    let isTyping = PublishSubject<Bool>()
    
    init(gameID: String,
         gameStatusUseCase: GameStatusUseCase,
         fetchGameDetailUseCase: FetchGameDetailUseCase,
         fetchMessagesUseCase: FetchMessagesUseCase,
         gameRoundPostUseCase: GameRoundPostUseCase,
         postMessageUseCase: PostMessageUseCase,
         userTypingMsgUseCase: UserTypingMessageUseCase,
         fetchMoreMsgsUseCase: FetchMoreMessagesUseCase,
         currentUser: User) {
        self.gameID = gameID
        self.gameStatusUseCase = gameStatusUseCase
        self.fetchGameDetailUseCase = fetchGameDetailUseCase
        self.fetchMessagesUseCase = fetchMessagesUseCase
        self.gameRoundPostUseCase = gameRoundPostUseCase
        self.postMessageUseCase = postMessageUseCase
        self.userTypingMsgUseCase = userTypingMsgUseCase
        self.fetchMoreMsgsUseCase = fetchMoreMsgsUseCase
        self.currentSender = Self.transformUserToChatUser(currentUser)
    }
    
    // MARK: - Input
    func viewDidLoad() {
        self.gameStatusUseCase.joinGame()
        self.listenFetchMessages()
        self.executeListeners()
    }
    
    func sendNewMessage(message: String) {
        let chatMessage = self.requestNewMessageForSending(message: message)
        self.storeAndSendNewMessage(chatMessage: chatMessage)
        
        let sendDateInt = Int(chatMessage.sentDate.timeIntervalSince1970)
        let creationDateMs = Double(sendDateInt) * 1000
        
        let newMessage = Message(id: chatMessage.messageId,
                                 text: message,
                                 timestampMs: creationDateMs,
                                 type: .user,
                                 user: .init(id: self.currentSender.senderId,
                                             userName: self.currentSender.displayName,
                                             avatarType: self.currentSender.avatarType),
                                 status: chatMessage.status)
        
        self.postMessageUseCase.sendNewMessage(gameId: self.gameID,
                                               message: newMessage) { [weak self] message in
            
            // Replace `Fake` send Message with the server one
            guard let self = self, let index = self.messages.firstIndex(where: { $0.messageId == chatMessage.messageId }) else { return }
            self.messages[index] = self.transformMessageToChatUserMessage(newMessage)
            self.updateNewMessageSended.onNext(self.messages)
        }
    }
    
    func loadMoreMessages() {
        guard let lastMessageId = self.messages.first?.messageId else {
            return
        }
        
        self.currentPage += 1
        self.fetchMoreMsgsUseCase.execute(
            limit: Self.LIMIT_PER_PAGE,
            currentPage: self.currentPage,
            lastMessageId: lastMessageId,
            gameId: self.gameID) { [weak self] (localMessages, remoteMessages) in
                guard let self = self else { return }
                
                if let remoteMessages = remoteMessages {
                    localMessages.forEach { message in
                        if let index = self.messages.firstIndex(where: {$0.messageId == message.id}) {
                            self.messages.remove(at: index)
                        }
                    }
                    let chatMessages: [ChatMessage] = remoteMessages.map(self.transformMessageToChatMessage)
                    self.messages.insert(contentsOf: chatMessages, at: 0)
                    self.didLoadMoreMessages.onNext(self.messages)
                } else {
                    let chatMessages: [ChatMessage] = localMessages.map(self.transformMessageToChatMessage)
                    self.messages.insert(contentsOf: chatMessages, at: 0)
                    self.didLoadMoreMessages.onNext(self.messages)
                }
        }
    }
    
    func didTapLeftButtonOnSystemMsg() {
        guard let gameAction = currentGame?.action else {
            return
        }
        
        switch gameAction {
        case .startGame:
            gameStatusUseCase.declineGame { [weak self] isPassed in
                if isPassed {
                    self?.updatePositionChatSystemMessage(nil)
                }
            }
        case .postRound:
            gameRoundPostUseCase.post(type: .ping)
        }
    }
    
    func didTapRightButtonOnSystemMsg() {
        guard let gameAction = currentGame?.action else {
            return
        }
        
        switch gameAction {
        case .startGame:
            gameStatusUseCase.startGame { [weak self] game in
                self?.currentGame = game
                self?.updatePositionChatSystemMessage(game.action)
            }
        case .postRound:
            gameRoundPostUseCase.post(type: .pong)
        }
    }
    
    func userTypingAction(isTyping: Bool) {
        isTyping ? self.userTypingMsgUseCase.startTyping() : self.userTypingMsgUseCase.stopTyping()
    }
    
    // MARK: - Private
    private func executeListeners() {
        fetchGameDetailUseCase.execute { [weak self] game in
            guard let self = self else { return }
            self.currentGame = game
            
            if let gameAction = self.currentGame?.action {
                let chatSystem = self.transformGameToChatSystemMessage(gameAction)
                self.messages.append(chatSystem)
            }
            
            self.messagesLoaded.accept(self.messages)
        }
        
        postMessageUseCase.messagePosted { [weak self] message in
            guard let self = self else { return }
            
            let chatMessage = self.transformMessageToChatMessage(message)
            self.storeAndSendNewMessage(chatMessage: chatMessage)
        }
        
        gameRoundPostUseCase.roundPosted { [weak self] game in
            guard let self = self else { return }
            self.currentGame = game
            self.updatePositionChatSystemMessage(game.action)
        }
        
        gameStatusUseCase.gameStarted { [weak self] game in
            guard let self = self else { return }
            self.currentGame = game
            self.updatePositionChatSystemMessage(game.action)
        }
        
        userTypingMsgUseCase.userIsTyping { [weak self] isTyping in
            self?.isTyping.onNext(isTyping)
        }
    }
    
    private func listenFetchMessages() {
        fetchMessagesUseCase.execute(gameID: self.gameID, limit: Self.LIMIT_PER_PAGE, offset: 0) { [weak self] messages in
            guard let self = self else { return }
            var chatMessages: [ChatMessage] = messages.map(self.transformMessageToChatMessage)
            
            if let gameAction = self.currentGame?.action {
                let chatSystem = self.transformGameToChatSystemMessage(gameAction)
                chatMessages.append(chatSystem)
            }
            
            self.messages = chatMessages
            self.messagesLoaded.accept(self.messages)
        }
    }
    
    // MARK: - Helpers
    private func storeAndSendNewMessage(chatMessage: ChatMessage) {
        self.messages.append(chatMessage)
        self.newMessageReceived.onNext(chatMessage)
    }
    
    private func requestNewMessageForSending(message: String) -> ChatUserMessage {
        return ChatUserMessage(message: message,
                               user: self.currentSender,
                               messageId: UUID().uuidString,
                               date: Date(),
                               status: .sending)
    }
    
    private func updatePositionChatSystemMessage(_ gameAction: GameAction?) {
        if let gameAction = gameAction {
            let chatMsg = self.transformGameToChatSystemMessage(gameAction)
            self.messages.append(chatMsg)
            self.updateChatSystemMessage.onNext(.insertion(self.messages.count - 1, chatMsg))
        } else {
            guard let index = self.messages.firstIndex(where: { $0 is ChatSystemMessage }) else {
                return
            }
            self.messages.remove(at: index)
            self.updateChatSystemMessage.onNext(.deletion(index))
        }
        
//        if let index = self.messages.firstIndex(where: { $0 is ChatSystemMessage }) {
//            self.messages.remove(at: index)
//            self.updateChatSystemMessage.onNext(.deletion(index))
//        } else {
//            guard let gameAction = gameAction else {
//                return
//            }
//
//        }
    }
    
    // MARK: - Transform
    private func transformMessageToChatMessage(_ message: Message) -> ChatMessage {
        switch message.type {
        case .bot:
            return self.transformMessageToChatBotMessage(message)
        case .user, .opponent:
            return self.transformMessageToChatUserMessage(message)
        }
    }
    
    private func transformMessageToChatUserMessage(_ message: Message) -> ChatUserMessage {
        return .init(message: message.text,
                     user: Self.transformUserToChatUser(message.user),
                     messageId: message.id,
                     date: message.timestampMs.msToDate,
                     status: message.status)
    }
    
    private func transformMessageToChatBotMessage(_ message: Message) -> ChatBotMessage {
        return .init(message: message.text,
                     messageId: message.id,
                     date: message.timestampMs.msToDate)
    }
    
    private func transformGameToChatSystemMessage(_ gameAction: GameAction) -> ChatSystemMessage {
        return .init(messageId: UUID().uuidString,
                     date: Date(),
                     gameAction: gameAction)
    }
    
    private static func transformUserToChatUser(_ user: User) -> ChatUserMessage.ChatUser {
        return .init(avatarType: user.avatarType,
                     senderId: user.id,
                     displayName: user.userName)
    }
}
