//
// HelperFunctions
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == LogString {
    public func string(isSensitive: Bool) -> String {
        "[ \(self.map { "\"\($0)\": \($1.string(isSensitive: isSensitive))" }.joined(separator: ", ")) ]"
    }
}

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
    context: String,
    isSensitive: Bool
) -> String {
    [
        time,
        "\(level.map { "\($0)" } ?? "")",
        "\(label)",
        context,
        message().string(isSensitive: isSensitive),
        meta()?.string(isSensitive: isSensitive).replacingOccurrences(of: "\n", with: " ") // TODO: serialize map manually
    ]
    .compactMap { $0 }
    .filter { !$0.isEmpty }
    .joined(separator: " ")
}
