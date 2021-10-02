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
	
	override func viewDidLoad() {
		NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: emailTextField)
	}
	
	@IBAction func signIn(_ sender: Any) {
		guard let email = emailTextField.text else { return }
		
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
	}

	@objc func textDidChange(_ note: Notification) {
		signInButton.isEnabled = emailTextField.text?.uuIsValidEmail() ?? false
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
