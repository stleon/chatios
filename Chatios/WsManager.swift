//
//  WsManager.swift
//  Chatios
//
//  Created by stleon on 02/11/2018.
//  Copyright © 2018 stleon. All rights reserved.
//

import Starscream

class WsManager: WebSocketDelegate {
    static let connection = WsManager()

    var socket: WebSocket = WebSocket(url: URL(string: "ws://localhost:8080/ws")!)

    func establish() {
        socket.delegate = self
        socket.connect()
    }
    
    func close() {
        if socket.isConnected {
            socket.disconnect()
        }
    }

    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect", error ?? "")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage", text)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData", data)
    }

}
