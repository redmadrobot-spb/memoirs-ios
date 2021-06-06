//
// MetricsMemoir
// Conveyor
//
// Created by Alex Babaev on 30 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

protocol AppMetrics {
    var calculatedMetrics: [String: MeasurementValue] { get }
    func subscribeOnMetricEvents(
        listener: @escaping ((measurements: [String: MeasurementValue], meta: [String: SafeString])) -> Void
    ) -> Any?
}

extension AppMetrics {
    func subscribeOnMetricEvents(
        listener: @escaping ((measurements: [String: MeasurementValue], meta: [String: SafeString])) -> Void
    ) -> Any? {
        nil
    }
}

public class MetricsMemoir {
    private var memoir: Memoir?
    private var timer: Timer?

    private let metricExtractors: [AppMetrics]
    private var metricSubscriptions: [Any] = []

    public init(memoir: Memoir? = nil) {
        #if os(Linux)
        metricExtractors = [ LinuxSystemMetrics() ]
        #elseif canImport(MetricKit) && os(iOS)
        if #available(iOS 13.0, *) {
            metricExtractors = [ MetricKitAppMetrics(), DarwinSystemMetrics() ]
        } else {
            metricExtractors = [ DarwinSystemMetrics() ]
        }
        #elseif canImport(Darwin)
        metricExtractors = [ DarwinSystemMetrics() ]
        #else
        metricExtractors = [ VoidAppMetrics() ]
        #endif

        self.memoir = memoir.map { TracedMemoir(object: self, memoir: $0) }

        metricSubscriptions = metricExtractors.compactMap { $0.subscribeOnMetricEvents(listener: send(metrics:meta:)) }
    }

    public func start(period: TimeInterval) {
        stop()
        let timer = Timer(timeInterval: period, repeats: true) { _ in
            self.memoir?.verbose("Timer fired")
            self.measureProcessorAndMemoryFootprint()
        }
        RunLoop.current.add(timer, forMode: .default)
        self.timer = timer
        memoir?.debug("Started; interval: \(period)")
    }

    public func stop() {
        guard timer != nil else { return }

        timer?.invalidate()
        timer = nil
        memoir?.debug("Stopped")
    }

    private func measureProcessorAndMemoryFootprint() {
        metricExtractors.forEach { extractor in
            send(metrics: extractor.calculatedMetrics, meta: [:])
        }
    }

    private func send(metrics: [String: MeasurementValue], meta: [String: SafeString]) {
        guard let memoir = memoir.map({TracedMemoir(tracer: .custom("metrics.\(UUID().uuidString)"), meta: meta, memoir: $0)}) else { return }

        metrics
            .sorted { lhs, rhs in lhs.key < rhs.key }
            .forEach { memoir.measurement(name: $0, value: $1) }
    }
}
