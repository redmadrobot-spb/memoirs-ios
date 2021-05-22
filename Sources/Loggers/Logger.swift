//
// Logger
// Robologs
//
// Created by Alex Babaev on 22 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class Logger: TracedLogger {
    public init(label: String, logger: Loggable, file: String = #file, function: String = #function, line: UInt = #line) {
        super.init(tracer: .label(label), meta: [:], logger: logger, file: file, function: function, line: line)
    }

    public convenience init(object: Any, logger: Loggable, file: String = #file, function: String = #function, line: UInt = #line) {
        self.init(label: String(describing: type(of: object)), logger: logger, file: file, function: function, line: line)
    }
}
