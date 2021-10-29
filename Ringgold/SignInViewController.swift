//
//  ViewController.swift
//  Ringgold
//
//  Created by Maurice Parker on 10/1/21.
//

import UIKit
import Snippets

class SignInViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet var topConstraint: NSLayoutConstraint!
	@IBOutlet var centerYConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		emailTextField.delegate = self
		signInButton.role = .primary

		topConstraint.constant = 100
		topConstraint.isActive = false

		NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: emailTextField)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@IBAction func signIn(_ sender: Any) {
		guard let email = emailTextField.text else { return }
		
		if email.uuIsValidEmail() {
			Snippets.Microblog.requestUserLoginEmail(email: email, appName: "Ringgold", redirect: "ringgold://signin?token=") { requestError in
				DispatchQueue.main.async {
					if let requestError = requestError {
						self.presentError(requestError)
					} else {
						AppDefaults.shared.username = email
						self.showConfirmation()
						self.emailTextField.resignFirstResponder()
					}
				}
			}
		} else {
			Snippets.Microblog.requestPermanentTokenFromTemporaryToken(token: email) { (requestError, permanentToken) in
				guard requestError == nil, let permanentToken = permanentToken else { return }
				DispatchQueue.main.async {
					AppDefaults.shared.username = "test_user"
					try? TokenManager.storeToken(permanentToken)
				}
			}
		}
		
	}

	@objc func keyboardWillShow(_ note: Notification) {
		self.centerYConstraint.isActive = false
		self.topConstraint.isActive = true
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
	
	@objc func keyboardWillHide(_ note: Notification) {
		self.centerYConstraint.isActive = true
		self.topConstraint.isActive = false
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
	
	@objc func textDidChange(_ note: Notification) {
		signInButton.isEnabled = !(emailTextField.text?.isEmpty ?? true)
	}
	
}

extension SignInViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if traitCollection.userInterfaceIdiom == .mac {
			signIn(self)
		}
		return false
	}
	
}

private extension SignInViewController {
	
	func showConfirmation() {
		let title = NSLocalizedString("Request Sent", comment: "Request Sent")
		let message = NSLocalizedString("Your email request has been sent. Check your email for the sign-in email.", comment: "Request Sent Message")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismissTitle = NSLocalizedString("OK", comment: "OK")
		let dismissAction = UIAlertAction(title: dismissTitle, style: .default)
		alertController.addAction(dismissAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
}
