//
// VoidAppMetrics
// Conveyor
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

final class VoidAppMetrics: AppMetrics {
    var calculatedMetrics: [String: MeasurementValue] {
        [:]
    }
}
