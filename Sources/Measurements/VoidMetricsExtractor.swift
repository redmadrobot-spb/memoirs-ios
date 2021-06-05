//
// LinuxMetricsExtractor
// Conveyor
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

final class VoidMetricsExtractor: MetricsExtractor {
    var calculatedMetrics: [String: Double] {
        [:]
    }

    func subscribeOnMetricEvents(listener: @escaping ([String: Double]) -> Void) -> Any? {
        nil
    }
}
