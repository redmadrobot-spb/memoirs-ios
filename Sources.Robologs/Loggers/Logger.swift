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

    public init(label: String, scopes: [Scope], logger: Loggable) {
        self.label = label
        self.scopes = scopes
        self.logger = logger
    }

    convenience public init(label: String, logger: Loggable) {
        if let logger = logger as? ScopedLoggable {
            self.init(label: label, logger: logger)
        } else {
            self.init(label: label, scopes: [], logger: logger)
        }
    }

    convenience public init(scopes: [Scope], logger: Loggable) {
        if let logger = logger as? LabeledLoggable {
            self.init(scopes: scopes, logger: logger)
        } else {
            self.init(label: "???", scopes: scopes, logger: logger)
        }
    }

    convenience public init(label: String, logger: ScopedLoggable) {
        let proxiedLogger = (logger as? LoggableProxy).map { $0.logger } ?? logger
        self.init(label: label, scopes: logger.scopes, logger: proxiedLogger)
    }

    convenience public init(scopes: [Scope], logger: LabeledLoggable) {
        let proxiedLogger = (logger as? LoggableProxy).map { $0.logger } ?? logger
        self.init(label: logger.label, scopes: scopes, logger: proxiedLogger)
    }

    convenience public init(object: Any, scopes: [Scope], logger: Loggable) {
        self.init(label: String(describing: type(of: object)), scopes: scopes, logger: logger)
    }

    convenience public init(object: Any, logger: Loggable) {
        self.init(label: String(describing: type(of: object)), logger: logger)
    }

    convenience public init(object: Any, logger: ScopedLoggable) {
        self.init(label: String(describing: type(of: object)), logger: logger)
    }
}
