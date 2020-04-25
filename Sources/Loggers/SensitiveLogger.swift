//
//  SensitiveLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 21.02.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Dispatch

public class SensitiveLogger: Logger {
    private let logger: Logger
    private let queue = DispatchQueue(label: "com.redmadrobot.robologs.SensitiveLogger", attributes: .concurrent)
    private var isCensorshipOn: Bool = true

    /// Creates a new instance of `SensitiveLogger`.
    /// - Parameter logger: Logger to which will redirect log events that have already been cleared of sensitive data.
    public init(logger: Logger) {
        self.logger = logger
    }

    public func log(
        level: Level,
        label: String,
        message: () -> LogString,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        queue.sync {
            logger.log(
                level: level,
                message: { "\(isCensorshipOn ? message().string(isSensitive: true) : message())" },
                label: label,
                meta: { meta()?.mapValues { "\(isCensorshipOn ? $0.string(isSensitive: true) : $0)" } },
                file: file,
                function: function,
                line: line
            )
        }
    }

    /// Sets the need to erase all sensitive data. Thread-safe.
    func excludeSensitive(_ isExcluded: Bool) {
        queue.async(flags: .barrier) {
            self.isCensorshipOn = isExcluded
        }
    }
}
