//
//  SceneDelegate.swift
//  Ringgold
//
//  Created by Maurice Parker on 10/1/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = scene as? UIWindowScene else { return }

		window = UIWindow(windowScene: windowScene)
		let viewController = newSignInController()

		window?.rootViewController = viewController
		
		#if targetEnvironment(macCatalyst)
		windowScene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 400)
		windowScene.sizeRestrictions?.maximumSize = CGSize(width: 400, height: 400)
		#endif
		
		window?.makeKeyAndVisible()
	}

}

private extension SceneDelegate {
	
	func newSignInController() -> UIViewController {
		return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
	}
	
}
