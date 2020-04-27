//
//  PeriodicBurstsLogsViewController.swift
//  Example
//
//  Created by Roman Mazeev on 29.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Robologs

class RandomizedLogsViewController: UIViewController {
    @IBOutlet private var logsTextView: UITextView!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var loadIntensityProgressView: UIProgressView!
    private var logsGenerator: RandomizedRecordGenerator!
    private var currentLogNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        logsGenerator = RandomizedRecordGenerator()
        loadIntensityProgressView.progress = 0
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

    @IBAction func actionButtonTapped() {
        if logsGenerator.isPlaying {
            logsGenerator.stop()
            actionButton.setTitle("Start", for: .normal)
            actionButton.backgroundColor = .systemBlue
            loadIntensityProgressView.progress = 0
        } else {
            logsGenerator.start()
            actionButton.setTitle("Stop", for: .normal)
            actionButton.backgroundColor = .systemRed
            loadIntensityProgressView.progress = logsGenerator.logIntensity
        }
    }
}
