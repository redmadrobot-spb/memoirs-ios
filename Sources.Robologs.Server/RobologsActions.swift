//
// RobologsActionsHandler
// sdk-apple
//
// Created by Alex Babaev on 30 April 2021.
//

import Foundation
import NIOHTTP1

public class RobologsActions: HttpActions {
    let senderId: String

    public init(senderId: String) {
        self.senderId = senderId
        super.init(actions: [])

        actions.append { request in
            guard request.method == .GET, request.version == 1, request.path == "/websocket" else { return nil }

            return .init(status: .ok, headers: [:], body: Data())
        }
    }
}
