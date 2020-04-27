//
// Logger
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
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
