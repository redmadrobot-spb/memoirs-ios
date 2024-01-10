//
// MemoirItem
// Memoirs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

public enum MemoirItem: Sendable {
    case log(level: LogLevel)
    case event(name: String)
    case measurement(name: String, value: MeasurementValue)
    case tracer(Tracer, isFinished: Bool)
}
