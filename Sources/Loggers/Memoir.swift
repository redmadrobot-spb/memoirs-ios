//
// Appendable
// Robologs
//
// Created by Alex Babaev on 09 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Appendable is able to append Memoir items to itself.
/// Usually it either streams items to console-like output, or resends them in some way.
public protocol Memoir {
    /// Method appends Memoir item to a Memoir.
    /// - Parameters:
    ///  - item: Item to append.
    ///  - meta: Parameters of the item.
    ///  - tracers: Tracers that group items in some way.
    ///  - date: date and time of the item creation.
    ///  - file: The path to the file from which the method was called. Usually you should use the #file literal for this.
    ///  - function: The function name from which the method was called. Usually you should use the #function literal for this.
    ///  - line: The line of code from which the method was called. Usually you should use the #line literal for this.
    func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    )
}
