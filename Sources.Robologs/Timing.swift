//
// Timing
// sdk-apple
//
// Created by Alex Babaev on 30 April 2021.
//

import Foundation

public protocol Timing {
    func start(label: String) -> PerformanceMonitor
    @discardableResult
    func lap(_ monitor: PerformanceMonitor) -> PerformanceMonitor
    @discardableResult
    func finish(_ monitor: PerformanceMonitor) -> PerformanceMonitor

    func check<T>(label: String, _ closure: () -> T) -> T
}

public extension Timing {
    func check<T>(label: String, _ closure: () -> T) -> T {
        let monitor = start(label: label)
        let result = closure()
        _ = finish(monitor)
        return result
    }
}
