//
//  LogsGeneratorTiming.swift
//  Example
//
//  Created by Roman Mazeev on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation

class LogsGeneratorTiming {
    private let period: TimeInterval
    private var timer: Timer?
    private var currentTime: TimeInterval = 0
    private var onTick: ((_ range: TimeRange) -> Void)?

    init(period: TimeInterval) {
        self.period = period
    }

    func start(_ onTick: @escaping (_ range: TimeRange) -> Void) {
        let timer = Timer(timeInterval: period, target: self, selector: #selector(fired), userInfo: nil, repeats: true)
        self.onTick = onTick
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        onTick = nil
        timer = nil
        currentTime = 0
    }

    @objc private func fired() {
        let newTime = currentTime + period
        onTick?(TimeRange(currentTime: newTime, previousTime: currentTime))
        currentTime = newTime
    }
}
