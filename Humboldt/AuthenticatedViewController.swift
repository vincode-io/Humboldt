//
//  AuthenticatedViewController.swift
//  Humboldt
//
//  Created by Maurice Parker on 10/1/21.
//

import UIKit

class AuthenticatedViewController: UIViewController {
	
	@IBAction func openShortcuts(_ sender: Any) {
		UIApplication.shared.open(URL(string: "shortcuts://")!, options: [:])
	}
	
	@IBAction func signOut(_ sender: Any) {
		try? TokenManager.removeToken()
	}
	
}
