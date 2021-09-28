//
// MemoirItem
// Memoirs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

public enum MemoirItem {
    case log(level: LogLevel, message: @autoclosure () -> SafeString)
    case event(name: String)
    case measurement(name: String, value: MeasurementValue)
    case tracer(Tracer, isFinished: Bool)
}
