//
//  ChatViewController.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 25/11/2021.
//

import UIKit

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource, InputBarAccessoryViewDelegate, MessagesDisplayDelegate, MessagesLayoutDelegate, MessageCellDelegate {

    // MARK: - Public properties
    lazy var messageList: [ChatMessage] = []
    var onRequestSendMessage: ((String) -> Void)?

    // MARK: - Private properties
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
        ChatDateHeaderViewCell.registerNibFor(collectionView: messagesCollectionView)
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(.primaryColor.withAlphaComponent(0.3),
                                                 for: .highlighted)
    }
    
    // MARK: - Public
    @objc func loadMoreMessages() {}
    
    func canShowRetryAccessoryView(for message: MessageType) -> Bool {
        return false
    }
    
    func configureLayout(_ layout: MessagesCollectionViewFlowLayout) {
        layout.sectionInset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right, textInsets: .zero))
        layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)))
        
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageIncomingCellBottomLabelAlignment(.init(textAlignment: .left, textInsets: .zero))
        layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)))
        
        // Configure spacing label text message
        layout.attributedTextMessageSizeCalculator.incomingMessageLabelInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        layout.attributedTextMessageSizeCalculator.outgoingMessageLabelInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: ChatMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    private func getPreviousMessage(at indexPath: IndexPath) -> MessageType? {
        guard indexPath.section - 1 >= 0 else { return nil }
        return messageList[indexPath.section - 1]
    }
    
    private func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let previousMsg = self.getPreviousMessage(at: indexPath) else { return false }
        return messageList[indexPath.section].sender.senderId == previousMsg.sender.senderId
    }
    
    private func getNextMessage(at indexPath: IndexPath) -> MessageType? {
        guard indexPath.section + 1 < messageList.count else { return nil }
        return messageList[indexPath.section + 1]
    }
    
    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let nextMsg = self.getNextMessage(at: indexPath) else { return false }
        return messageList[indexPath.section].sender.senderId == nextMsg.sender.senderId
    }
    
    // MARK: - Display Helpers
    private func isDateLabelVisible(section: Int) -> Bool {
        let indexPath = IndexPath(row: 0, section: section)
        guard let previousMsg = self.getPreviousMessage(at: indexPath) else {
            return true
        }
        return previousMsg.sentDate.onlyDate != self.messageList[indexPath.section].sentDate.onlyDate
    }
    
    private func hasMessageBottomLabel(for message: MessageType, at indexPath: IndexPath) -> Bool {
        if message is ChatLoadingMessage {
            return false
        }
        
        if (message as? ChatUserMessage)?.status == .couldNotSend,
           self.isFromCurrentSender(message: message) {
            return false
        }
        
        // If msg is more than 10 min show message bottom
        if let nextMsg = getNextMessage(at: indexPath),
           nextMsg.sentDate.timeIntervalSince(message.sentDate) > 600 {
            return true
        }
        
        if !isNextMessageSameSender(at: indexPath) {
            return true
        }
        return false
    }
    
    private func hasCellBottomLabel(for message: MessageType) -> Bool {
        if let userMsg = message as? ChatUserMessage, userMsg.status == .couldNotSend,
           self.isFromCurrentSender(message: message) {
            return true
        }
        return false
    }
    
    // MARK: - MessagesDataSource
    func currentSender() -> SenderType {
        assertionFailure("Must be override")
        fatalError()
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !self.hasMessageBottomLabel(for: message, at: indexPath) { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [
            .font: UIFont.gv_smallBody(),
            .foregroundColor: UIColor.gv_grey
        ])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !self.hasCellBottomLabel(for: message) { return nil }
        
        return NSAttributedString(string: "Echec d’envoi du message", attributes: [.foregroundColor: UIColor(hexa: "#e12424"), .font: UIFont.gv_smallBody()])
    }
    
    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        return nil
    }
    
    // Header
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        
        let date = messageList[indexPath.section].sentDate
        func getDate() -> String {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                return "Aujhourd'hui"
            }
            else if calendar.isDateInYesterday(date) {
                return "Hier"
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            return dateFormatter.string(from: date)
        }
        
        let vc = ChatDateHeaderViewCell.reusableViewForCollection(collectionView: messagesCollectionView, indexPath: indexPath)
        vc.configure(text: getDate())
        return vc
    }
}

// MARK: - MessageInputBarDelegate
extension ChatViewController {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    private func processInputBar(_ inputBar: InputBarAccessoryView) {
        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        inputBar.inputTextView.resignFirstResponder()
        
        if let userMessage = components.first(where: { $0 is String }) as? String {
            self.onRequestSendMessage?(userMessage)
        }
    }
    
    @objc func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {}
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .darkText
    }
    
    // All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .gv_sunny : UIColor(hexa: "#f6f6f6")
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.topRight)
            corners.formUnion(.bottomLeft)
            
            if isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomRight)
            
            if isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 14
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let userMsg = message as? ChatUserMessage, userMsg.status == .couldNotSend {
            avatarView.image = UIImage(named: "retry_message_icon")
        }
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController {
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        if self.isDateLabelVisible(section: section) {
            return CGSize(width: messagesCollectionView.bounds.width, height: 44)
        }
        return .zero
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return self.hasMessageBottomLabel(for: message, at: indexPath) ? 26 : 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return self.hasCellBottomLabel(for: message) ? 18 : 0
    }
}

// MARK: - MessageCellDelegate
extension ChatViewController {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView),
            (message as? ChatUserMessage)?.status == .couldNotSend else {
                return
        }
        
        self.didTapAvatarRetryTextMessageTapped(messageId: message.messageId)
    }
    
    func didTapAvatarRetryTextMessageTapped(messageId: String) { }
}

extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
}
