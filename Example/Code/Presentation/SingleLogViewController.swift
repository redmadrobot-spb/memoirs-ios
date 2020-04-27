//
//  SingleLogViewController.swift
//  Example
//
//  Created by Roman Mazeev on 28.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Robologs

class SingleLogViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var logsTextView: UITextView!
    @IBOutlet private var selectedLogLevelSegmentedControl: UISegmentedControl!
    @IBOutlet private var labelTextField: UITextField!
    @IBOutlet private var messageTextField: UITextField!
    @IBOutlet private var sensitiveSwitcher: UISwitch!
    @IBOutlet private var formBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var formStackView: UIStackView!
    private var logger: Logger!
    private var currentLogNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        setupKeyboardShowing()
        sensitiveSwitcher.isOn = false
    }

    private func setupLogger() {
        let diagnosticLogger = DiagnosticLogger { [weak self] diagnosticLogger in
            guard let self = self else { return }

            self.logsTextView.text = diagnosticLogger.lastLogs.reversed().joined(separator: "\n")
            self.currentLogNumber = diagnosticLogger.lastLogs.count
        }

        logger = MultiplexingLogger(
            loggers: [
                RemoteLoggerService.shared.logger,
                diagnosticLogger,
            ]
        )
    }

    private func setupKeyboardShowing() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        if formBottomConstraint.constant <= keyboardSize.height {
            formBottomConstraint.constant = keyboardSize.height

            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        formBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func sendLogButtonTapped() {
        logger.log(
            level: Level.allCases[selectedLogLevelSegmentedControl.selectedSegmentIndex],
            sensitiveSwitcher.isOn ? "\(messageTextField.text ?? "")" : "\(safe: messageTextField.text ?? "")",
            label: labelTextField.text ?? ""
        )
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == labelTextField {
            messageTextField.becomeFirstResponder()
            return true
        } else if textField == messageTextField {
            messageTextField.resignFirstResponder()
            return true
        } else {
            return true
        }
    }
}
