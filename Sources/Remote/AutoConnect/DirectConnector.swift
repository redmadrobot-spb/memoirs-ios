//
// DirectConnector
// Robologs
//
// Created by Alex Babaev on 15 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class DirectConnector: NSObject, URLSessionWebSocketDelegate {
    private var session: URLSession!
    private var task: URLSessionWebSocketTask?

    override init() {
        super.init()

        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    func listenForConnection() {
//        session.
    }
}
