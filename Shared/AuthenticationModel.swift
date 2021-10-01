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
	
	@Published var authenticated: Bool = false

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

	func start() {
		do {
			if try TokenManager.retrieveToken() != nil {
				authenticated = true
			}
		} catch {
			self.error = error
		}
	}
	
	func requestUserLoginEmail() {
		Snippets.Microblog.requestUserLoginEmail(email: email, appName: "Ringgold", redirect: "ringgold://signin?token=") { requestError in
			DispatchQueue.main.async {
				if let requestError = requestError {
					self.error = requestError
				} else {
					AppDefaults.shared.username = self.email
					self.showConfirmation = true
				}
			}
		}
	}
	
	func processTemporaryToken(_ temporaryToken: String) {
		Snippets.Microblog.requestPermanentTokenFromTemporaryToken(token: temporaryToken) { (requestError, permanentToken) in
			DispatchQueue.main.async {
				if let requestError = requestError {
					self.error = requestError
					return
				}
				
				if let permanentToken = permanentToken {
					do {
						try TokenManager.storeToken(permanentToken)
						self.authenticated = true
					} catch {
						self.error = error
					}
				}
			}
		}
	}
	
	func signOff() {
		do {
			try TokenManager.removeToken()
			self.authenticated = false
		} catch {
			self.error = error
		}
	}
	
}
