//
// MemoirItem
// Robologs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

public enum MemoirItem {
    case log(level: LogLevel, message: @autoclosure () -> SafeString)
    case event(name: Swift.String)
    case measurement(name: Swift.String, value: Double)
    case tracer(Tracer, isFinished: Bool)
}
