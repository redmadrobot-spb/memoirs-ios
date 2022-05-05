//
// MeasurementValue
// Memoirs
//
// Created by Alex Babaev on 6 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

public enum MeasurementValue: Sendable {
    public struct HistogramBucket: Sendable {
        public var range: Range<Double>
        public var count: Int

        public init(range: Range<Double>, count: Int) {
            self.range = range
            self.count = count
        }
    }

    case double(Double)
    case int(Int64)
    case meta // all data is stored in a meta field
    case histogram(buckets: [HistogramBucket]) // range ends are exclusive

    var isZero: Bool {
        switch self {
            case .double(let value):
                return value.isZero
            case .int(let value):
                return value == 0
            case .meta:
                return false
            case .histogram(let buckets):
                return buckets.isEmpty || buckets.allSatisfy { bucket in bucket.count == 0 }
        }
    }
}
