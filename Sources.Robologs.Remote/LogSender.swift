//
// Created by Alex Babaev on 23.04.2021.
//

import Foundation

public protocol LogSender {
    func send(message: SerializedLogMessage)
}
