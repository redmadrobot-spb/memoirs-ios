//
//  SingleLogViewController.swift
//  Example
//
//  Created by Roman Mazeev on 28.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Robologs

class SingleLogViewController: UIViewController {
    @IBOutlet private var logsTextView: UITextView!
    @IBOutlet private var selectedLogLevelSegmentedControl: UISegmentedControl!
    private var logger: Logger!
    private var currentLogNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        logsTextView.isEditable = false
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

    @IBAction func sendLogButton() {
        logger.log(
            level: Level.allCases[selectedLogLevelSegmentedControl.selectedSegmentIndex],
            label: "Log number: \(currentLogNumber)",
            message: { "Test message" },
            meta: { nil },
            file: #file,
            function: #function,
            line: #line
        )
    }
}
