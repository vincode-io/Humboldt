//
//  AuthenticationModel.swift
//  Ringgold
//
//  Created by Maurice Parker on 9/30/21.
//

import Foundation
import SwiftUI
import Snippets

public enum AuthenticationModelError: LocalizedError {
	case invalidOrMissingToken
	
	public var errorDescription: String? {
		return NSLocalizedString("The email token is no longer valid. Please request another one.", comment: "Invalid token")
	}
	
}

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
			guard requestError == nil else { return }
			
			DispatchQueue.main.async {
				// For some reason we are getting called twice. Once with an error that isn't real and then
				// with a token that works.
				
//				if let requestError = requestError {
//					if requestError is Snippets.SnippetsError {
//						self.error = AuthenticationModelError.invalidOrMissingToken
//					} else {
//						self.error = requestError
//					}
//					return
//				}
				
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
