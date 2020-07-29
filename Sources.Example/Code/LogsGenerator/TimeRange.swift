//
// TimeRange
// Example
//
// Created by Roman Mazeev on 30.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

struct TimeRange {
    let currentTime: TimeInterval
    let previousTime: TimeInterval

    var interval: TimeInterval {
        currentTime - previousTime
    }
}
