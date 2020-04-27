//
// Logger
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Robologs

extension Level {
    static var allCases: [Level] {
        [
            .verbose,
            .debug,
            .info,
            .warning,
            .error,
            .critical,
        ]
    }
}
