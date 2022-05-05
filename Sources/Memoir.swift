//
// Memoir
// Memoirs
//
// Created by Alex Babaev on 09 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Appendable is able to append Memoir items to itself.
/// Usually it either streams items to console-like output, or resends them in some way.
public protocol Memoir: Sendable {
    /// Method appends Memoir item to a Memoir.
    /// - Parameters:
    ///  - item: Item to append.
    ///  - meta: Parameters of the item.
    ///  - tracers: Tracers that group items in some way.
    ///  - timeIntervalSinceReferenceDate: date and time of the item creation.
    ///  - file: The path to the file from which the method was called. Usually you should use the #fileID literal for this.
    ///  - function: The function name from which the method was called. Usually you should use the #function literal for this.
    ///  - line: The line of code from which the method was called. Usually you should use the #line literal for this.
    func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    )
}

//public extension Memoir {
//    func append(
//        _ item: MemoirItem,
//        meta: @autoclosure () -> [String: SafeString]?,
//        tracers: [Tracer],
//        date: Date,
//        file: String, function: String, line: UInt
//    ) {
//        let date = date.timeIntervalSinceReferenceDate
//        append(item, meta: meta(), tracers: tracers, timeIntervalSinceReferenceDate: date, file: file, function: function, line: line)
//    }
//}
