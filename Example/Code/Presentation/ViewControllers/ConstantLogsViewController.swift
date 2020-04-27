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
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var loadIntensitySlider: UISlider!
    private var logsGenerator: LogsGenerator!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        configureLogsGenerator()
    }

    private var logText: String = ""

    private func setupLogger() {
        Loggers.instance.bufferLoggerHandler = { [weak self] logs in
            guard let self = self else { return }

            self.logText += logs.joined(separator: "\n") + "\n"
            if self.logText.count > 8192 {
                self.logText = String(self.logText.suffix(8192))
            }
            self.logsTextView.text = self.logText
            self.logsTextView.scrollRectToVisible(
                CGRect(x: 0, y: self.logsTextView.contentSize.height - 1, width: 1, height: 1),
                animated: false
            )
        }
    }

    private var position: UInt64 = 0
    private var nextPosition: UInt64 {
        position += 1
        return position
    }

    private func configureLogsGenerator() {
        let recordsGenerator = UniformRecordGenerator(
            record: {
                GeneratedLogRecord(
                    level: Level.allCases.randomElement() ?? .info,
                    label: "ConstantLog",
                    message: "Test message \(self.nextPosition)")

            },
            recordsPerSecond: Double(loadIntensitySlider.value * 100)
        )

        logsGenerator = LogsGenerator(
            timing: LogsGeneratorTiming(period: 0.2),
            recordGenerator: recordsGenerator
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
