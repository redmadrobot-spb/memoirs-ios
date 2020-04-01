//
//  ConstantLoadLogsViewController.swift
//  Example
//
//  Created by Roman Mazeev on 29.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Robologs

class ConstantLogsViewController: UIViewController {
    @IBOutlet private var logsTextView: UITextView!
    @IBOutlet private var actionButton: ActionButton!
    @IBOutlet private var loadIntensitySlider: UISlider!
    private var logger: Logger!
    private var logsGenerator: LogsGenerator!
    private var currentLogNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        configureLogsGenerator()
    }

    private func setupLogger() {
        let diagnosticLogger = DiagnosticLogger { [weak self] diagnosticLogger in
            guard let self = self else { return }

            self.logsTextView.text = diagnosticLogger.lastLogs.reversed().joined(separator: "\n")
            self.currentLogNumber = diagnosticLogger.lastLogs.count
        }

        if let remoteLogger = RemoteLoggerService.logger {
            logger = MultiplexingLogger(loggers: [
                remoteLogger,
                diagnosticLogger
            ])
        } else {
            logger = diagnosticLogger
        }
    }

    private func configureLogsGenerator() {
        let recordsGenerator = UniformRecordGenerator(
            record: {
                GeneratedLogRecord(
                    level: Level.allCases.randomElement() ?? .info,
                    label: "Log number: \(self.currentLogNumber)",
                    message: "Test message")

            },
            recordsPerSecond: Double(loadIntensitySlider.value * 100)
        )

        logsGenerator = LogsGenerator(
            timing: LogsGeneratorTiming(period: 0.2),
            recordGenerator: recordsGenerator,
            logger: logger
        )
    }

    @IBAction func actionButtonTapped() {
        if logsGenerator.isPlaying {
            logsGenerator.stop()
            actionButton.setTitle("Start", for: .normal)
            actionButton.backgroundColor = .systemBlue
            loadIntensitySlider.isEnabled = true
        } else {
            logsGenerator.start()
            actionButton.setTitle("Stop", for: .normal)
            actionButton.backgroundColor = .systemRed
            loadIntensitySlider.isEnabled = false
        }
    }

    @IBAction func loadIntensityChanged() {
        configureLogsGenerator()
    }
}
