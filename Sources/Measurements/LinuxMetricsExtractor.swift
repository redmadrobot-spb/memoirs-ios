//
// LinuxMetricsExtractor
// Conveyor
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

final class LinuxMetricsExtractor: MetricsExtractor {
    var calculatedMetrics: [String: Double] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = [ "-p", "\(ProcessInfo.processInfo.processIdentifier)", "-efo", "%cpu,%mem" ]
        let outPipe = Pipe()
        process.standardOutput = outPipe
        let errPipe = Pipe()
        process.standardError = errPipe
        try? process.run()

        let outputString = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        let output = outputString?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .last?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty } ?? []

        process.waitUntilExit()

        if output.count >= 2 {
            let cpuPercent = output[0]
            var memory = output[1].uppercased()
            if memory.hasSuffix("T") {
                let memoryValue: UInt = (UInt(memory.replacingOccurrences(of: "T", with: "")) ?? 0) * 1024 * 1024 * 1024 * 1024
                memory = "\(memoryValue)"
            } else if memory.hasSuffix("G") {
                let memoryValue: UInt = (UInt(memory.replacingOccurrences(of: "G", with: "")) ?? 0) * 1024 * 1024 * 1024
                memory = "\(memoryValue)"
            } else if memory.hasSuffix("M") {
                let memoryValue: UInt = (UInt(memory.replacingOccurrences(of: "M", with: "")) ?? 0) * 1024 * 1024
                memory = "\(memoryValue)"
            } else if memory.hasSuffix("K") {
                let memoryValue: UInt = (UInt(memory.replacingOccurrences(of: "K", with: "")) ?? 0) * 1024
                memory = "\(memoryValue)"
            }

            var result: [String: Double] = [:]
            if let cpuPercent = Double(cpuPercent) {
                result[MetricsMemoir.keyCPUUsagePercent] = cpuPercent
            }
            if let memoryPercent = Double(memory) {
                result[MetricsMemoir.keyMemoryUsagePercent] = memoryPercent
            }
            return result
        } else {
            return [:]
        }
    }

    func subscribeOnMetricEvents(listener: @escaping ([String: Double]) -> Void) -> Any? {
        nil
    }
}
