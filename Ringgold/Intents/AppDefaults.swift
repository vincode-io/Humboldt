//
//  AppDefaults.swift
//  Ringgold
//
//  Created by Maurice Parker on 9/30/21.
//

import Foundation

final class AppDefaults {

	static let shared = AppDefaults()
	private init() {}
	
	static var store: UserDefaults = {
		let organizationIdentifier = Bundle.main.object(forInfoDictionaryKey: "OrganizationIdentifier") as! String
		let suiteName = "group.\(organizationIdentifier).Ringgold"
		return UserDefaults.init(suiteName: suiteName)!
	}()
	
	struct Key {
		static let username = "userID"
	}

	var username: String? {
		get {
			Self.string(for: Key.username)
		}
		set {
			Self.setString(for: Key.username, newValue)
		}
	}

}

private extension AppDefaults {

	static func string(for key: String) -> String? {
		return AppDefaults.store.string(forKey: key)
	}
	
	static func setString(for key: String, _ value: String?) {
		AppDefaults.store.set(value, forKey: key)
	}

	static func bool(for key: String) -> Bool {
		return AppDefaults.store.bool(forKey: key)
	}

	static func setBool(for key: String, _ flag: Bool) {
		AppDefaults.store.set(flag, forKey: key)
	}

	static func int(for key: String) -> Int {
		return AppDefaults.store.integer(forKey: key)
	}
	
	static func setInt(for key: String, _ x: Int) {
		AppDefaults.store.set(x, forKey: key)
	}
	
	static func date(for key: String) -> Date? {
		return AppDefaults.store.object(forKey: key) as? Date
	}

	static func setDate(for key: String, _ date: Date?) {
		AppDefaults.store.set(date, forKey: key)
	}
	
	static func data(for key: String) -> Data? {
		return AppDefaults.store.object(forKey: key) as? Data
	}

	static func setData(for key: String, _ data: Data?) {
		AppDefaults.store.set(data, forKey: key)
	}
	
}
