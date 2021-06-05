//
// Statistics
// Memoirs
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation
import MemoirSubscriptions

#if canImport(MetricKit) && os(iOS)

import MetricKit

final class MetricKitMetricsExtractor: NSObject, MetricsExtractor, MXMetricManagerSubscriber {
    private var metricManager: MXMetricManager?

    override init() {
        super.init()

        metricManager = MXMetricManager.shared
        metricManager?.add(self)
    }

    deinit {
        metricManager?.remove(self)
    }

    private var currentMetrics: [String: Double] = [:]
    private let currentMetricsQueue: DispatchQueue = DispatchQueue(label: "MetricKitMetricsExtractor", qos: .utility)

    func didReceive(_ payloads: [MXMetricPayload]) {
        currentMetricsQueue.async {
            guard let metrics = payloads.last else { return }

            if let cpuMetrics = metrics.cpuMetrics {
                self.currentMetrics[MetricsMemoir.keyCPUUsagePercent] = cpuMetrics.cumulativeCPUTime.converted(to: .seconds).value
            }
            if let cpuMetrics = metrics.cpuMetrics {
                self.currentMetrics[MetricsMemoir.keyCPUUsagePercent] = cpuMetrics.cumulativeCPUTime.converted(to: .seconds).value
            }
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        currentMetricsQueue.async {
            payloads.forEach {

            }
        }
    }

    var calculatedMetrics: [String: Double] {
        currentMetricsQueue.sync(flags: .barrier) { currentMetrics }
    }

    private let subscribers: Subscribers<[String: Double]> = .init()

    func subscribeOnMetricEvents(listener: @escaping ([String: Double]) -> Void) -> Any? {
        subscribers.subscribe(listener)
    }
}
#endif
