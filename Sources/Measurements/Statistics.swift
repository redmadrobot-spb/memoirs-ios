//
// Statistics
// sdk-apple
//
// Created by Alex Babaev on 30 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

public class Statistics {
    private var memoir: Memoir?
    private var timer: Timer?

    private let cpuPercentUsageMeasurementName: String
    private let memoryUsageMeasurementName: String
    private let memoryPercentUsageMeasurementName: String

    public init(
        cpuPercentUsageMeasurementName: String = "cpuUsagePercent",
        memoryUsageMeasurementName: String = "memoryUsage",
        memoryPercentUsageMeasurementName: String = "memoryUsagePercent",
        memoir: Memoir? = nil
    ) {
        self.cpuPercentUsageMeasurementName = cpuPercentUsageMeasurementName
        self.memoryUsageMeasurementName = memoryUsageMeasurementName
        self.memoryPercentUsageMeasurementName = memoryPercentUsageMeasurementName
        self.memoir = memoir.map { TracedMemoir(object: self, memoir: $0) }
    }

    public func start(period: TimeInterval) {
        stop()
        let timer = Timer(timeInterval: period, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .default)
        self.timer = timer
        memoir?.debug("Started; interval: \(period)")
    }

    @objc
    private func timerFired(_ timer: Timer) {
        memoir?.verbose("Timer fired")
        measureProcessorAndMemoryFootprint()
    }

    public func stop() {
        guard timer != nil else { return }

        timer?.invalidate()
        timer = nil
        memoir?.debug("Stopped")
    }

    private func measureProcessorAndMemoryFootprint() {
        if let stats = MyProcess.stats {
            memoir?.measurement(name: cpuPercentUsageMeasurementName, value: Double(stats.cpuPercent) ?? 0)
            if let memory = stats.memory {
                memoir?.measurement(name: memoryUsageMeasurementName, value: Double(memory) ?? 0)
            }
            if let memoryPercent = stats.memoryPercent {
                memoir?.measurement(name: memoryPercentUsageMeasurementName, value: Double(memoryPercent) ?? 0)
            }
        }
    }
}

enum MyProcess {
    static var stats: (cpuPercent: String, memory: String?, memoryPercent: String?)? {
        let process = Process()
        #if os(Linux)
        process.launchPath = "/bin/ps"
        process.arguments = [ "-p", "\(ProcessInfo.processInfo.processIdentifier)", "-efo", "%cpu,%mem" ]
        #else
        process.launchPath = "/usr/bin/top"
        process.arguments = [ "-stats", "cpu,mem", "-pid", "\(ProcessInfo.processInfo.processIdentifier)", "-l", "1" ]
        #endif
        let outPipe = Pipe()
        process.standardOutput = outPipe
        let errPipe = Pipe()
        process.standardError = errPipe
        process.launch()

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
                let memoryValue = (UInt(memory.replacingOccurrences(of: "T", with: "")) ?? 0) * 1024 * 1024 * 1024 * 1024
                memory = "\(memoryValue)"
            } else if memory.hasSuffix("G") {
                let memoryValue = (UInt(memory.replacingOccurrences(of: "G", with: "")) ?? 0) * 1024 * 1024 * 1024
                memory = "\(memoryValue)"
            } else if memory.hasSuffix("M") {
                let memoryValue = (UInt(memory.replacingOccurrences(of: "M", with: "")) ?? 0) * 1024 * 1024
                memory = "\(memoryValue)"
            } else if memory.hasSuffix("K") {
                let memoryValue = (UInt(memory.replacingOccurrences(of: "K", with: "")) ?? 0) * 1024
                memory = "\(memoryValue)"
            }

            #if os(Linux)
            return (cpuPercent, memory, nil)
            #else
            return (cpuPercent, nil, memory)
            #endif
        } else {
            return nil
        }
    }
}
//    #else
//    enum Process {
//        private static let basicInfoCount = mach_msg_type_number_t(MemoryLayout<task_basic_info_data_t>.size /  MemoryLayout<UInt32>.size)
//        private static let vmInfoCount = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<UInt32>.size)
//
//        static var cpuUsage: Double? {
//            var threadsArray: thread_act_array_t?
//            var threadCount: mach_msg_type_number_t = 0
//            guard task_threads(mach_task_self_, &threadsArray, &threadCount) == KERN_SUCCESS else { return nil }
//            guard let threads = threadsArray else { return nil }
//
//            defer {
//                let size = MemoryLayout<thread_t>.size * Int(threadCount)
//                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(size))
//            }
//
//            return (0 ..< Int(threadCount))
//                .map { index in
//                    var info = thread_basic_info()
//                    var infoCount = basicInfoCount
//                    let result = withUnsafeMutablePointer(to: &info) {
//                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                            thread_info(threads[index], thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
//                        }
//                    }
//                    guard result == KERN_SUCCESS else { return 0 }
//
//                    return info.flags & TH_FLAGS_IDLE == 0 ? Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0 : 0
//                }
//                .reduce(0.0, +)
//        }
//
//        static var memoryUsage: Int? {
//            var info = task_vm_info_data_t()
//            var infoCount = vmInfoCount
//            let result = withUnsafeMutablePointer(to: &info) {
//                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                    task_info(mach_task_self_, thread_flavor_t(TASK_VM_INFO), $0, &infoCount)
//                }
//            }
//            guard result == KERN_SUCCESS else { return nil }
//
//            return Int(info.internal)
//        }
//    }
//    #endif
