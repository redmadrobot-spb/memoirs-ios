//
//  EventEmmiter.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Robologs

class LogsGenerator {
    private let timing: LogsGeneratorTiming
    private let recordGenerator: LogGeneratorRecordGenerator
    private let logger: Logger
    private(set) var isPlaying: Bool = false

    init(
        timing: LogsGeneratorTiming,
        recordGenerator: LogGeneratorRecordGenerator,
        logger: Logger
    ) {
        self.timing = timing
        self.recordGenerator = recordGenerator
        self.logger = logger
    }

    func start() {
        isPlaying = true
        timing.start { range in
            self.recordGenerator.records(for: range).forEach { generatedRecord in
                self.logger.log(
                    level: generatedRecord.level,
                    label: generatedRecord.label,
                    message: "\(public: generatedRecord.message)",
                    meta: generatedRecord.meta?.mapValues { "\(public: $0)" as LogString } ?? [:]
                )
            }
        }
    }

    func stop() {
        isPlaying = false
        timing.stop()
    }
}
