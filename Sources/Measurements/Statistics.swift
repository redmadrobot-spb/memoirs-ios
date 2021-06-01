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

    private let cpuUsageMeasurementName: String
    private let memoryUsageMeasurementName: String

    public init(
        cpuUsageMeasurementName: String = "cpuUsagePercent", memoryUsageMeasurementName: String = "memoryUsage", memoir: Memoir? = nil
    ) {
        self.cpuUsageMeasurementName = cpuUsageMeasurementName
        self.memoryUsageMeasurementName = memoryUsageMeasurementName
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
        if let cpuUsage = Process.cpuUsage {
            memoir?.measurement(name: cpuUsageMeasurementName, value: cpuUsage)
        }
        if let memoryUsage = Process.memoryUsage {
            memoir?.measurement(name: memoryUsageMeasurementName, value: Double(memoryUsage))
        }
    }
}

enum Process {
    private static let basicInfoCount = mach_msg_type_number_t(MemoryLayout<task_basic_info_data_t>.size /  MemoryLayout<UInt32>.size)
    private static let vmInfoCount = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<UInt32>.size)

    static var cpuUsage: Double? {
        var threadsArray: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0
        guard task_threads(mach_task_self_, &threadsArray, &threadCount) == KERN_SUCCESS else { return nil }
        guard let threads = threadsArray else { return nil }

        defer {
            let size = MemoryLayout<thread_t>.size * Int(threadCount)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(size))
        }

        return (0 ..< Int(threadCount))
            .map { index in
                var info = thread_basic_info()
                var infoCount = basicInfoCount
                let result = withUnsafeMutablePointer(to: &info) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threads[index], thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
                    }
                }
                guard result == KERN_SUCCESS else { return 0 }

                return info.flags & TH_FLAGS_IDLE == 0 ? Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0 : 0
            }
            .reduce(0.0, +)
    }

    static var memoryUsage: Int? {
        var info = task_vm_info_data_t()
        var infoCount = vmInfoCount
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, thread_flavor_t(TASK_VM_INFO), $0, &infoCount)
            }
        }
        guard result == KERN_SUCCESS else { return nil }

        return Int(info.internal)
    }
}
