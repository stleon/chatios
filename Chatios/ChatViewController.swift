//
//  ChatViewController.swift
//  Chatios
//
//  Created by stleon on 02/11/2018.
//  Copyright © 2018 stleon. All rights reserved.
//


import UIKit

class ChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WsManager.connection.establish()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WsManager.connection.close()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
