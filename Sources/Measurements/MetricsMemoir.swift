//
// MetricsMemoir
// Conveyor
//
// Created by Alex Babaev on 30 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

protocol MetricsExtractor {
    var calculatedMetrics: [String: Double] { get }
    func subscribeOnMetricEvents(listener: @escaping ([String: Double]) -> Void) -> Any?
}

public class MetricsMemoir {
    static var keyCPUUsagePercent: String = "cpuUsagePercent"
    static var keyMemoryUsagePercent: String = "memoryUsagePercent"
    static var keyMemoryUsageValue: String = "memoryUsageValue"

    private var memoir: Memoir?
    private var timer: Timer?

    private let metricExtractors: [MetricsExtractor]
    private var metricSubscriptions: [Any] = []

    public init(memoir: Memoir? = nil) {
        #if os(Linux)
        metricExtractors = [ LinuxMetricsExtractor() ]
        #elseif canImport(MetricKit) && os(iOS)
        metricExtractors = [ MetricKitMetricsExtractor(), DarwinMetricsExtractor() ]
        #elseif canImport(Darwin)
        metricExtractors = [ DarwinMetricsExtractor() ]
        #else
        metricExtractors = [ VoidMetricsExtractor() ]
        #endif

        self.memoir = memoir.map { TracedMemoir(object: self, memoir: $0) }

        metricSubscriptions = metricExtractors.compactMap { $0.subscribeOnMetricEvents(listener: send(metrics:)) }
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
            send(metrics: extractor.calculatedMetrics)
        }
    }

    private func send(metrics: [String: Double]) {

    }
}
