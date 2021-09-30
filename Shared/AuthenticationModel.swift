//
//  AuthenticationModel.swift
//  Ringgold
//
//  Created by Maurice Parker on 9/30/21.
//

import Foundation
import SwiftUI
import Snippets

class AuthenticationModel: ObservableObject {
	
	@Published var email: String = ""
	@Published var error: Error? {
		didSet {
			if error == nil {
				showError = false
			} else {
				showError = true
			}
		}
	}
	@Published var showError: Bool = false
	@Published var showConfirmation: Bool = false

	func requestUserLoginEmail() {
		Snippets.Microblog.requestUserLoginEmail(email: email, appName: "Ringgold", redirect: "ringgold://signin?token=") { requestError in
			DispatchQueue.main.async {
				if let requestError = requestError {
					self.error = requestError
				} else {
					self.showConfirmation = true
				}
			}
		}
	}
	
}
