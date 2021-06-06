//
// MeasurementValue
// Memoirs
//
// Created by Alex Babaev on 6 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

public enum MeasurementValue {
    public struct HistogramBucket {
        public var range: Range<Double>
        public var count: Int

        public init(range: Range<Double>, count: Int) {
            self.range = range
            self.count = count
        }
    }

    case double(Double)
    case int(Int64)
    case histogram(buckets: [HistogramBucket]) // range ends are exclusive

    var isZero: Bool {
        switch self {
            case .double(let value):
                return value.isZero
            case .int(let value):
                return value == 0
            case .histogram(let buckets):
                return buckets.isEmpty || buckets.allSatisfy { bucket in bucket.count == 0 }
        }
    }
}
