//
// HelperFunctions
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

func collectContext(file: String = #file, function: String = #function, line: UInt = #line) -> String {
    // TODO: Remove this hack after Swift Evolution #0274 will be implemented
    let file = file.components(separatedBy: "/").last ?? "?"
    let context = [ file, function, (line == 0 ? "" : "\(line)") ]
        .filter { !$0.isEmpty }
        .joined(separator: ":")

    return context
}
