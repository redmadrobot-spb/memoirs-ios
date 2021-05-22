//
// Log.Item
// Robologs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

public extension Log {
    enum Item {
        case log(level: Log.Level, message: @autoclosure () -> Log.String)
        case event(name: Swift.String)
        case measurement(name: Swift.String, value: Double)
        case tracer(Log.Tracer, isFinished: Bool)
    }
}
