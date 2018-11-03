//
//  Message.swift
//  Chatios
//
//  Created by stleon on 02/11/2018.
//  Copyright © 2018 stleon. All rights reserved.
//

import Foundation
import UIKit
import MessageKit


struct Message {
    let sender: Sender
    let text: String
    let messageId: String
}

extension Message: MessageType {

    var sentDate: Date {
        return Date()
    }

    var kind: MessageKind {
        return .text(text)
    }

    static func generateId() -> String {
        return UUID().uuidString
    }

}
