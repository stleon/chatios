//
//  ChatViewController.swift
//  Chatios
//
//  Created by stleon on 02/11/2018.
//  Copyright © 2018 stleon. All rights reserved.
//


import UIKit
import MessageKit
import MessageInputBar

class ChatViewController: MessagesViewController {

    private var messages: [Message] = []
    private var sender: Sender!

    override func viewDidLoad() {
        super.viewDidLoad()
        WsManager.connection.establish()
        sender = Sender(id: "1", displayName: "123")
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WsManager.connection.close()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        WsManager.connection.close()
    }

}

extension ChatViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func currentSender() -> Sender {
        return Sender(id: sender.id, displayName: sender.displayName)
    }

    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return messages[indexPath.section]
    }

}

extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}

extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {

        return isFromCurrentSender(message: message) ? .blue : .gray
    }

}

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {

        let newMessage = Message(
            sender: sender,
            text: text,
            messageId: UUID().uuidString)

        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}
