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
    @IBOutlet private var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet private var connectionUrlTextField: UITextField!
    @IBOutlet private var connectionCodeTextField: UITextField!
    @IBOutlet private var secretTextField: UITextField!
    @IBOutlet private var formStackView: UIStackView!
    @IBOutlet private var formBottomConstraint: NSLayoutConstraint!
    private var loadingView: UIView!

    private var isLoading = false {
        didSet {
            loadingView.isHidden = !isLoading
            doneBarButtonItem.isEnabled = !isLoading
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoadingView()
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
        formBottomConstraint.constant = (view.frame.height / 2) - (formStackView.frame.height / 2)
        addDoneButtonOnConnectionCodeKeyboard()
    }

    @IBAction func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    @IBAction func doneButtonTapped() {
        isLoading = true

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
                transport.startLiveSession(self.connectionCodeTextField.text ?? "")
                self.isLoading = false
                self.dismiss(animated: true)
            }
        }
    }

    private func showErrorAlert() {
        self.isLoading = false
        let alert = UIAlertController(title: "Can not connect", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    private func setupLoadingView() {
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        loadingView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2)
        loadingView.layer.cornerRadius = 20
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.center = loadingView.center
        loadingView.center = view.center
        loadingView.addSubview(activityIndicator)
        self.view.addSubview(loadingView)
        loadingView.isHidden = !isLoading
        self.loadingView = loadingView
    }

    private func addDoneButtonOnConnectionCodeKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 50
            )
        )

        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButtonItem = UIBarButtonItem(
            title: "Next", style: .done, target: self, action: #selector(self.connectionCodeNextAction))

        doneToolbar.items = [flexSpace, doneBarButtonItem]
        doneToolbar.sizeToFit()

        connectionCodeTextField.inputAccessoryView = doneToolbar
    }

    @objc private func connectionCodeNextAction() {
        secretTextField.becomeFirstResponder()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        if formBottomConstraint.constant <= keyboardSize.height {
            formBottomConstraint.constant = keyboardSize.height + 16

            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        formBottomConstraint.constant = (view.frame.height / 2) - (formStackView.frame.height / 2)

         UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
         }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == connectionUrlTextField {
            connectionCodeTextField.becomeFirstResponder()
            return true
        } else if textField == secretTextField {
            doneButtonTapped()
            return true
        } else {
            return true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, textField == connectionCodeTextField else { return true }

        let compSepByCharInSet = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered && text.count < 6
    }
}
