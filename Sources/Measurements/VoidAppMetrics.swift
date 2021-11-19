//
// VoidAppMetrics
// Conveyor
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

final class VoidAppMetrics: MetricsRetriever {
    var calculatedMetrics: [String: MeasurementValue] {
        [:]
    }
}
