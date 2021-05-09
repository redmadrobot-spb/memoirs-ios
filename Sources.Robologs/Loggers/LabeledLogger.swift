//
// LabeledLogger
// Robologs
//
// Created by Dmitry Shadrin on 06.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class LabeledLogger: LabeledLoggable, LoggableProxy {
    public let label: String
    public let logger: Loggable

    public init(label: String, logger: Loggable) {
        self.label = label
        self.logger = logger
    }

    convenience public init(object: Any, logger: Loggable) {
        self.init(label: String(describing: type(of: object)), logger: logger)
    }
}
