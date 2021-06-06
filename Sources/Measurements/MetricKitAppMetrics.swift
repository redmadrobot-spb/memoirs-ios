//
// MetricKitAppMetrics
// Memoirs
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation
import MemoirSubscriptions

#if canImport(MetricKit) && os(iOS)

import MetricKit

final class MetricKitAppMetrics: NSObject, AppMetrics, MXMetricManagerSubscriber {
    private var metricManager: MXMetricManager?

    override init() {
        super.init()

        metricManager = MXMetricManager.shared
        metricManager?.add(self)
    }

    deinit {
        metricManager?.remove(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach { payload in
//            payload.
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        payloads.forEach {

        }
    }

    var calculatedMetrics: [String: Double] {
        [:]
    }

    private let subscribers: Subscribers<([String: Double], Tracer)> = .init()

    func subscribeOnMetricEvents(listener: @escaping ([String: Double]) -> Void) -> Any? {
        subscribers.subscribe(listener)
    }
}
#endif
