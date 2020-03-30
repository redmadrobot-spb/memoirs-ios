//
//  PeriodicBurstsLogsViewController.swift
//  Example
//
//  Created by Roman Mazeev on 29.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Robologs

class PeriodicBurstsLogsViewController: UIViewController {
    @IBOutlet private var logsTextView: UITextView!
    @IBOutlet private var actionButton: ActionButton!
    @IBOutlet private var loadIntensityProgressView: UIProgressView!
    private var logger: Logger!
    private var logsGenerator: RealApplicationLogGenerator!
    private var currentLogNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        setupLogsGenerator()
        logsTextView.isEditable = false
        loadIntensityProgressView.progress = 0
    }

    private func setupLogsGenerator() {
        logsGenerator = RealApplicationLogGenerator(logger: logger)
    }

    private func setupLogger() {
        let diagnosticLogger = DiagnosticLogger { [weak self] diagnosticLogger in
            guard let self = self else { return }

            self.logsTextView.text = diagnosticLogger.lastLogs.reversed().joined(separator: "\n")
            self.currentLogNumber = diagnosticLogger.lastLogs.count
        }

        if let remoteLogger = RemoteLoggerService.logger {
            self.logger = MultiplexingLogger(loggers: [
                remoteLogger,
                diagnosticLogger
            ])
        } else {
            self.logger = diagnosticLogger
        }
    }

    @IBAction func actionButtonTapped() {
        if logsGenerator.isPlaying {
            logsGenerator.stop()
            actionButton.setTitle("Start", for: .normal)
            actionButton.backgroundColor = .systemBlue
            loadIntensityProgressView.progress = 0
        } else {
            self.logsGenerator.start()
            actionButton.setTitle("Stop", for: .normal)
            actionButton.backgroundColor = .systemRed
            loadIntensityProgressView.progress = logsGenerator.logIntensity
        }
    }
}
