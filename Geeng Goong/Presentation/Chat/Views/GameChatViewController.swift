//
//  GameChatViewController.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 25/11/2021.
//

import UIKit
import RxSwift

final class GameChatViewController: ChatViewController {
    
    var viewModel: GameChatViewModel!
    private let disposeBag = DisposeBag()
    private var isTyping: Bool = false
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        let layout = GameChatFlowLayout()
        self.configureLayout(layout)
        messagesCollectionView.setCollectionViewLayout(layout, animated: false)
        ChatSystemViewCell.registerNibFor(collectionView: messagesCollectionView)
        ChatLoadingMessageViewCell.registerNibFor(collectionView: messagesCollectionView)
        
        self.bindViewModel()
        self.viewModel.viewDidLoad()
        
        self.onRequestSendMessage = { [weak self] userMessage in
            self?.viewModel.sendNewMessage(message: userMessage)
        }
        
        let navTitleView = ChatNavTitleView()
        self.navigationItem.titleView = navTitleView.createView(navBarWidth: self.navigationController?.navigationBar.bounds.width)
        DispatchQueue.main.async {
            navTitleView.showSkeleton()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            navTitleView.configure(image: UIImage(named: "racket_icon"), title: "Conversation")
            navTitleView.configure(isOnline: true)
        }
        
        // For test placeholders :
//        self.messageList = [ChatLoadingMessage(senderId: self.currentSender().senderId), ChatLoadingMessage(senderId: ""), ChatLoadingMessage(senderId: ""), ChatLoadingMessage(senderId: self.currentSender().senderId), ChatLoadingMessage(senderId: self.currentSender().senderId)]
//        self.messagesCollectionView.reloadData()
//        self.messagesCollectionView.scrollToLastItem()
    }
    
    override func currentSender() -> SenderType {
        return self.viewModel.currentSender
    }
    
    // MARK: - Private
    private func bindViewModel() {
        viewModel.messagesLoaded
            .subscribe(onNext: { [weak self] messages in
                self?.messageList = messages
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem()
            })
            .disposed(by: disposeBag)
        
        viewModel.newMessageReceived
            .subscribe(onNext: { [weak self] message in
                self?.insertMessage(message)
            })
            .disposed(by: disposeBag)
        
        viewModel.updateNewMessageSended
            .subscribe(onNext: { [weak self] messages in
                self?.messageList = messages
            })
            .disposed(by: disposeBag)
        
        viewModel.didLoadMoreMessages
            .subscribe(onNext: { [weak self] messages in
                self?.messageList = messages
                self?.messagesCollectionView.reloadDataAndKeepOffset()
                self?.refreshControl.endRefreshing()
                if messages.isEmpty {
                    self?.messagesCollectionView.refreshControl = nil
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.updateChatSystemMessage
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .deletion(let index):
                    self.messageList.remove(at: index)
                    self.messagesCollectionView.deleteSections([index])
                case .insertion(let index, let chatMessage):
                    self.messageList.insert(chatMessage, at: index)
                    self.messagesCollectionView.insertSections([index])
                }
                
                self.messagesCollectionView.scrollToLastItem()
            })
            .disposed(by: disposeBag)
        
        viewModel.isTyping
            .subscribe(onNext: { [weak self] isTyping in
                self?.setTypingIndicatorViewHidden(!isTyping, animated: true)
                self?.messagesCollectionView.scrollToLastItem()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Override
    override func loadMoreMessages() {
        self.viewModel.loadMoreMessages()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            #if DEBUG
            fatalError("Ouch. nil data source for messages")
            #else
            return super.collectionView(collectionView, cellForItemAt: indexPath)
            #endif
        }
        //before checking the messages check if section is reserved for typing otherwise it will cause IndexOutOfBounds error
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind, let chatSystem = message as? ChatSystemMessage {
            let cell = ChatSystemViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
            cell.configure(dataView: chatSystem.gameAction.chatBotDataView)
            cell.didTapLeftButton = { [weak self] in
                self?.viewModel.didTapLeftButtonOnSystemMsg()
            }
            cell.didTapRightButton = { [weak self] in
                self?.viewModel.didTapRightButtonOnSystemMsg()
            }
            return cell
        }
        if case .custom = message.kind, message is ChatLoadingMessage {
            let cell = ChatLoadingMessageViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
            cell.configure(messageWidth: collectionView.bounds.width / 1.5,
                           isStackLeft: self.currentSender().senderId != message.sender.senderId)
            cell.showSkeleton()
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    override func canShowRetryAccessoryView(for message: MessageType) -> Bool {
        guard let userMessage = message as? ChatUserMessage,
              userMessage.status == .couldNotSend else {
            return false
        }
        return true
    }
}

// MARK: - User Typing
extension GameChatViewController {
    
    override func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        super.inputBar(inputBar, textViewTextDidChangeTo: text)
        
        if !isTyping {
            self.isTyping = true
            self.viewModel.userTypingAction(isTyping: true)
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self,selector: #selector(self.stopTyping), object: nil)
        self.perform(#selector(self.stopTyping), with: nil, afterDelay: 1.0)
    }
    
    @objc private func stopTyping() {
        self.isTyping = false
        self.viewModel.userTypingAction(isTyping: false)
    }
}
