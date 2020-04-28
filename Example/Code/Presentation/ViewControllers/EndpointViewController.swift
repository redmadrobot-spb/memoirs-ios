//
// EndpointViewController
// Example
//
// Created by Roman Mazeev on 28.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import UIKit
import Robologs

class EndpointViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var connectionUrlTextField: UITextField!
    @IBOutlet private var secretTextField: UITextField!
    @IBOutlet private var formStackView: UIStackView!
    @IBOutlet private var formBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var connectButton: UIButton!
    @IBOutlet private var codeStackView: UIStackView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var getCodeButton: UIButton!
    @IBOutlet private var connectionCodeLabel: UILabel!
    @IBOutlet private var disableSSLCheckSwitch: UISwitch!

    private var liveId: String? {
        didSet {
            connectionCodeLabel.text = liveId
        }
    }
    private var isConnecting: Bool = false {
        didSet {
            if isConnecting {
                activityIndicator.isHidden = false
                if !activityIndicator.isAnimating {
                    activityIndicator.startAnimating()
                }
                getCodeButton.isEnabled = false
                getCodeButton.alpha = 0.3
            } else {
                activityIndicator.isHidden = true
                if activityIndicator.isAnimating {
                    activityIndicator.stopAnimating()
                }
                getCodeButton.isEnabled = true
                getCodeButton.alpha = 1
            }
        }
    }
    private var isConnected: Bool = false {
        didSet {
            if isConnected {
                getCodeButton.isEnabled = true
                getCodeButton.alpha = 1
                connectButton.backgroundColor = UIColor.systemRed
                connectButton.setTitle("Disconnect", for: .normal)
            } else {
                getCodeButton.isEnabled = false
                getCodeButton.alpha = 0.3
                connectButton.backgroundColor = UIColor.systemBlue
                connectButton.setTitle("Connect to specified URL", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardShowing()

        isConnected = false
        connectionUrlTextField.text = "https://robologs.dev/log/api/v1"
        connectionCodeLabel.layer.cornerRadius = 8
        connectionCodeLabel.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
        connectionCodeLabel.layer.borderWidth = 1
    }

    private func setUI(enabled: Bool) {
        connectButton.isEnabled = enabled
        connectButton.alpha = enabled ? 1 : 0.3

        getCodeButton.isEnabled = isConnected
        getCodeButton.alpha = isConnected ? 1 : 0.3
    }

    // MARK: - Actions

    @IBAction
    private func getId() {
        liveId = nil
        isConnecting = true
        Loggers.instance.getCode { result in
            self.isConnecting = false
            switch result {
                case .success(let code):
                    self.liveId = code
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: "Could not get code: \(error)", preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
            }
        }
    }

    @IBAction
    func connectDisconnect() {
        setUI(enabled: false)
        if isConnected {
            liveId = nil
            Loggers.instance.disconnect {
                self.isConnected = false
                self.setUI(enabled: true)
            }
        } else {
            guard let urlString = connectionUrlTextField.text, let url = URL(string: urlString) else {
                self.isConnected = false
                self.setUI(enabled: true)

                let alert = UIAlertController(title: "Error", message: "Bad URL", preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .cancel))
                self.present(alert, animated: true)

                return
            }

            isConnecting = true
            let disableSSLCheck = disableSSLCheckSwitch.isOn
            Loggers.instance.connectAndGetCode(
                url: url,
                secret: secretTextField.text ?? "",
                disableSSLCheck: disableSSLCheck
            ) { result in
                self.isConnecting = false
                switch result {
                    case .success(let code):
                        self.liveId = code
                        self.isConnected = true
                    case .failure(let error):
                        self.isConnected = false

                        let alert = UIAlertController(title: "Error", message: "Could not connect: \(error)", preferredStyle: .alert)
                        alert.addAction(.init(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                }
                self.setUI(enabled: true)
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

    // MARK: - Keyboard Handling

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
}
