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
    private var can_send: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        WsManager.connection.establish()

        sender = Sender(id: "0", displayName: "_")

         WsManager.connection.socket.onData = { (data: Data) in

            // TODO: convert incoming data to swift tuple

            do {
                let message = try Bert.decode(data: data as NSData) as! BertTuple

                let tag = message.elements[0] as! BertAtom
                if tag.value == "msg" {
                    let tuple = message.elements[1] as! BertTuple
                    let t = tuple.elements[0] as! BertAtom
                    if t.value == "text" {
                        let binary = tuple.elements[1] as! BertBinary
                        let datastring = NSString(data: binary.value as Data, encoding: String.Encoding.utf8.rawValue)

                        let message = Message(
                            sender: Sender(id: "1", displayName: "_"),
                            text: datastring! as String,
                            messageId: Message.generateId())

                        self.messages.append(message)
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom(animated: true)
                    }
                } else if tag.value == "signal" {
                    let binary = message.elements[1] as! BertBinary
                    let datastring = NSString(data: binary.value as Data, encoding: String.Encoding.utf8.rawValue)

                    if datastring! as String == "channel_created" {
                        self.can_send = true
                    } else if datastring! as String == "typing" {
                        //
                    }

                }

            }
            catch {
                print("decode error")
            }

        }

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageInputBar.delegate = self
        messageInputBar.sendButton.title = "->"
        messageInputBar.inputTextView.placeholder = ""
        messageInputBar.inputTextView.isImagePasteEnabled = false

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }

        // self.inputIsActive(flag: false)

        WsManager.connection.socket.onDisconnect = { (error: Error?) in
            self.inputIsActive(flag: false)
        }
    }

    func inputIsActive(flag: Bool) -> Void {
        self.messageInputBar.sendButton.isEnabled = flag
        self.messageInputBar.shouldManageSendButtonEnabledState = flag
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

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType,
                             at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }

}

extension ChatViewController: MessageInputBarDelegate {

    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {

        if self.can_send {
            let newMessage = Message(
                sender: sender,
                text: text,
                messageId: Message.generateId())

            messages.append(newMessage)

            // convert to bert
            let tag = BertAtom(fromString: "msg")
            let tuple = BertTuple(fromElements: [BertAtom(fromString: "text"),
                                                 BertBinary(fromNSData: newMessage.text.data(using: .utf8)! as NSData)])
            let message = BertTuple(fromElements: [tag, tuple])


            do {
                let binary = try Bert.encode(object: message)
                WsManager.connection.send(data: binary as Data)
            }
            catch {
                print("encode error")
            }

            inputBar.inputTextView.text = ""
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToBottom(animated: true)
        }

    }
}
