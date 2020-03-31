//
//  EndpointViewController.swift
//  Example
//
//  Created by Roman Mazeev on 28.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Robologs

class EndpointViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var connectionUrlTextField: UITextField!
    @IBOutlet private var secretTextField: UITextField!
    @IBOutlet private var formStackView: UIStackView!
    @IBOutlet private var formBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var connectButton: ActionButton!
    @IBOutlet private var codeStackViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet private var codeStackView: UIStackView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var isLoading = false {
        didSet {
            activityIndicator.isHidden = !isLoading
            connectButton.isEnabled = !isLoading
        }
    }

    private var isConnected = false {
        didSet {
            codeStackView.isHidden = !isConnected
            connectButton.setTitle(isConnected ? "Disconnect" : "Connect", for: .normal)
            connectButton.backgroundColor = isConnected ? .systemRed : .systemBlue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardShowing()
        codeStackView.isHidden = true
    }

    @IBAction func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    private func showErrorAlert() {
        self.isLoading = false
        self.isConnected = false
        let alert = UIAlertController(title: "Can not connect", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    private func setupKeyboardShowing() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
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
            codeStackViewCenterConstraint.isActive = false
            formBottomConstraint.constant = keyboardSize.height

            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        formBottomConstraint.constant = 0
        codeStackViewCenterConstraint.isActive = true

         UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
         }
    }

    @IBAction func connectButtonTapped() {
        isLoading = true

        if isConnected {
            // TODO: Disconnect
        } else {
            guard let urlString = connectionUrlTextField.text, let url = URL(string: urlString) else {
                showErrorAlert()
                return
            }

            let transport = ProtoHttpRemoteLoggerTransport(endpoint: url, secret: secretTextField.text ?? "")
            transport.authorize { result in

                if case .failure = result {
                    self.showErrorAlert()
                } else {
                    RemoteLoggerService.logger = RemoteLogger(buffering: InMemoryBuffering(), transport: transport)
                    self.isLoading = false
                    self.isConnected = true
                }
            }
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == connectionUrlTextField {
            secretTextField.becomeFirstResponder()
        } else if textField == secretTextField {
            secretTextField.resignFirstResponder()
        }

        return true
    }
}
