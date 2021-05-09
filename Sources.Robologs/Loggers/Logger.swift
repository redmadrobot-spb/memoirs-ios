//
// Loggable
// Robologs
//
// Created by Dmitry Shadrin on 26.11.2019.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Default logger.
public class Logger: LoggableProxy, ScopedLoggable, LabeledLoggable {
    public let label: String
    public let scopes: [Scope]
    public let logger: Loggable

    public init(label: String, scopes: [Scope] = [], logger: Loggable) {
        self.label = label
        self.scopes = scopes
        self.logger = logger
    }

    convenience public init(object: Any, scopes: [Scope] = [], logger: Loggable) {
        self.init(label: String(describing: type(of: object)), scopes: scopes, logger: logger)
    }
}
