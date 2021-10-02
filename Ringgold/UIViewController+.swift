//
//  UIViewController+.swift
//  Ringgold
//
//  Created by Maurice Parker on 10/1/21.
//

import UIKit

extension UIViewController {
	
	func presentError(_ error: Error, dismiss: (() -> Void)? = nil) {
		let errorTitle = NSLocalizedString("Error", comment: "Error")
		presentError(title: errorTitle, message: error.localizedDescription, dismiss: dismiss)
	}
	
	public func presentError(title: String, message: String, dismiss: (() -> Void)? = nil) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismissTitle = NSLocalizedString("OK", comment: "OK")
		let dismissAction = UIAlertAction(title: dismissTitle, style: .default) { _ in
			dismiss?()
		}
		alertController.addAction(dismissAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
}
