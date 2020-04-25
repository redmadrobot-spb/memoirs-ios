//
// HelperFunctions
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

@inlinable
public func collectContext(file: String, function: String, line: UInt) -> String {
    // TODO: Remove this hack after Swift Evolution #0274 will be implemented
    let file = file.components(separatedBy: "/").last ?? "?"
    let context = [ file, line == 0 ? "" : "\(line)", function ]
        .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: ":")

    return context
}

@inlinable
public func concatenateData(
    time: String,
    level: Level?,
    message: () -> LogString,
    label: String,
    meta: () -> [String: LogString]?,
    context: String
) -> String {
    let parts = [
        time,
        "\(level.map { "\($0)" } ?? "")",
        "\(label)",
        context,
        "\(message())",
        meta().map { $0.isEmpty ? "" : "\($0)".replacingOccurrences(of: "\n", with: " ") }
    ]
    return parts
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
}
