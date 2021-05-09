//
// ScopedLogger
// Robologs
//
// Created by Alex Babaev on 07.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class ScopedLogger: LoggableProxy, ScopedLoggable {
    public let scopes: [Scope]
    public let logger: Loggable

    public init(scopes: [Scope], logger: Loggable) {
        self.scopes = scopes
        self.logger = logger
    }
}
