//
//  SceneDelegate.swift
//  Ringgold
//
//  Created by Maurice Parker on 10/1/21.
//

import UIKit
import Snippets

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = scene as? UIWindowScene else { return }

		window = UIWindow(windowScene: windowScene)

		let token = try? TokenManager.retrieveToken()
		if token != nil {
			window?.rootViewController = authenticatedController()
		} else {
			window?.rootViewController = newSignInController()
		}
		
		#if targetEnvironment(macCatalyst)
		windowScene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 400)
		windowScene.sizeRestrictions?.maximumSize = CGSize(width: 400, height: 400)
		#endif
		
		window?.makeKeyAndVisible()
		
		NotificationCenter.default.addObserver(self, selector: #selector(tokenDidChange(_:)), name: .TokenDidChange, object: nil)
	}

	func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
		guard let url = urlContexts.first?.url,
			  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
			  let temporaryToken = components.queryItems?.first?.value else {
				  return
			  }
		processTemporaryToken(temporaryToken)
	}
	
}

private extension SceneDelegate {
	
	@objc func tokenDidChange(_ note: Notification) {
		if note.userInfo?[TokenManager.tokenUserInfoKey] == nil {
			window?.rootViewController = newSignInController()
		} else {
			window?.rootViewController = authenticatedController()
		}
	}
	
	func newSignInController() -> UIViewController {
		return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
	}
	
	func authenticatedController() -> UIViewController {
		return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthenticatedViewController")
	}
	
	func processTemporaryToken(_ temporaryToken: String) {
		Snippets.Microblog.requestPermanentTokenFromTemporaryToken(token: temporaryToken) { (requestError, permanentToken) in
			guard requestError == nil, let permanentToken = permanentToken else { return }
			DispatchQueue.main.async {
				try? TokenManager.storeToken(permanentToken)
			}
		}
	}
	
}
