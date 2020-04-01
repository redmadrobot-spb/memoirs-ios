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
    @IBOutlet private var switchRemoteTypeButton: ActionButton!
    @IBOutlet private var codeStackViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet private var codeStackView: UIStackView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    enum State {
        case remote
        case loading
        case mock
    }

    private var state: State = .mock {
        didSet {
            activityIndicator.isHidden = state != .loading
            switchRemoteTypeButton.isEnabled = state != .loading
            codeStackView.isHidden = state != .remote

            switch state {
                case .remote:
                    switchRemoteTypeButton.backgroundColor = .systemRed
                    switchRemoteTypeButton.setTitle("Switch to mock", for: .normal)
                case .mock:
                    switchRemoteTypeButton.backgroundColor = .systemBlue
                    switchRemoteTypeButton.setTitle("Switch to remote", for: .normal)
                case .loading:
                    switchRemoteTypeButton.backgroundColor = .systemGray
                    switchRemoteTypeButton.setTitle("Loading", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardShowing()

        switch RemoteLoggerService.shared.type {
            case .mock:
                state = .mock
            case .remote:
                state = .remote
        }
    }

    @IBAction func cancelButtonTapped() {
        dismiss(animated: true)
    }

    private func showErrorAlert() {
        state = .mock
        let alert = UIAlertController(title: "Can not connect", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
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

    @IBAction func switchRemoteTypeButtonTapped() {
        if state == .remote {
            state = .loading
            let transport = MockRemoteLoggerTransport(logger: PrintLogger())
            RemoteLoggerService.shared.configureRemoteLogger(transport: transport)
            state = .mock
        } else if state == .mock {
            state = .loading
            guard let urlString = connectionUrlTextField.text, let url = URL(string: urlString) else {
                showErrorAlert()
                return
            }

            let transport = ProtoHttpRemoteLoggerTransport(endpoint: url, secret: secretTextField.text ?? "")
            RemoteLoggerService.shared.configureRemoteLogger(transport: transport)
            transport.authorize { result in
                if case .failure = result {
                    self.showErrorAlert()
                } else {
                    self.state = .remote
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
