//
// CPUMemoryMeasurements
// Conveyor
//
// Created by Alex Babaev on 30 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

protocol MetricsRetriever {
    var calculatedMetrics: [String: MeasurementValue] { get }
}

public class CPUMemoryMeasurements {
    private var memoir: Memoir!
    private var timer: Timer?

    private let metricsRetriever: MetricsRetriever

    public init(memoir: Memoir) {
        #if os(Linux)
        metricsRetriever = LinuxSystemMetrics()
        #elseif canImport(Darwin)
        metricsRetriever = DarwinSystemMetrics()
        #else
        metricsRetriever = VoidAppMetrics()
        #endif

        self.memoir = TracedMemoir(object: self, memoir: memoir)
    }

    public func start(period: TimeInterval) {
        stop()
        let timer = Timer(timeInterval: period, repeats: true) { _ in
            self.memoir.verbose("Timer fired")
            self.measureProcessorAndMemoryFootprint()
        }
        RunLoop.current.add(timer, forMode: .default)
        self.timer = timer
        memoir.debug("Started; interval: \(period)")
    }

    public func stop() {
        guard timer != nil else { return }

        timer?.invalidate()
        timer = nil
        memoir.debug("Stopped")
    }

    private func measureProcessorAndMemoryFootprint() {
        send(metrics: metricsRetriever.calculatedMetrics, meta: [:])
    }

    private func send(metrics: [String: MeasurementValue], meta: [String: SafeString]) {
        metrics
            .sorted { lhs, rhs in lhs.key < rhs.key }
            .forEach { memoir.measurement(name: $0, value: $1) }
    }
}
