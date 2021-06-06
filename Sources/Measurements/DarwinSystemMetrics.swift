//
// DarwinSystemMetrics
// Memoirs
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

#if canImport(Darwin)

import Darwin

final class DarwinSystemMetrics: AppMetrics {
    private let keyCPUUsagePercent: String = "cpuUsagePercent"
    private let keyMemoryUsageValue: String = "memoryUsageValue"

    private let basicInfoCount = mach_msg_type_number_t(MemoryLayout<task_basic_info_data_t>.size /  MemoryLayout<UInt32>.size)
    private let vmInfoCount = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<UInt32>.size)

    private var cpuUsage: Double? {
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

    private var memoryUsage: Int? {
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

    var calculatedMetrics: [String: Double] {
        var result: [String: Double] = [:]
        if let cpuUsage = cpuUsage {
            result[keyCPUUsagePercent] = cpuUsage
        }
        if let memoryUsage = memoryUsage {
            result[keyMemoryUsageValue] = Double(memoryUsage)
        }
        return result
    }

    func subscribeOnMetricEvents(listener: @escaping ([String: Double]) -> Void) -> Any? {
        nil
    }
}

#endif