//
// SingleLogViewController
// Example
//
// Created by Roman Mazeev on 28.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import UIKit
import Robologs

class SingleLogViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var logsTextView: UITextView!
    @IBOutlet private var selectedLogLevelSegmentedControl: UISegmentedControl!
    @IBOutlet private var labelTextField: UITextField!
    @IBOutlet private var messageTextField: UITextField!
    @IBOutlet private var formBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var formStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        setupKeyboardShowing()
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
        Loggers.instance.logger.log(
            level: Level.allCases[selectedLogLevelSegmentedControl.selectedSegmentIndex],
            "\(messageTextField.text ?? "empty log")",
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
