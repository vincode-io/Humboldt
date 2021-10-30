//
//  TokenManager.swift
//  Humboldt
//
//  Created by Maurice Parker on 9/30/21.
//

import Foundation
import Snippets

public extension Notification.Name {
	static let TokenDidChange = Notification.Name(rawValue: "TokenDidChange")
}

public enum TokenManagerError: Error {
	case unhandledError(status: OSStatus)
}

public struct TokenManager {
	
	public static let tokenUserInfoKey = "token"

	private static var keychainGroup: String? = {
		guard let appGroup = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as? String else {
			return nil
		}
		let appIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as! String
		let appGroupSuffix = appGroup.suffix(appGroup.count - 6)
		return "\(appIdentifierPrefix)\(appGroupSuffix)"
	}()
	
	private static var server: String = {
		let microBlogConfig = Snippets.Configuration.microblogConfiguration(token: "")
		let urlComponents = URLComponents(string: microBlogConfig.microblogEndpoint)
		return urlComponents!.host!
	}()

	public static func storeToken(_ token: String) throws {
		guard let username = AppDefaults.shared.username else { return }
		try storeToken(token, server: server, username: username)
	}
	
	static func retrieveToken() throws -> String? {
		guard let username = AppDefaults.shared.username else { return nil }
		return try retrieveToken(server: server, username: username)
	}
	
	static func removeToken() throws {
		guard let username = AppDefaults.shared.username else { return }
		try removeToken(server: server, username: username)
	}
	
}

private extension TokenManager {
	
	static func storeToken(_ token: String, server: String, username: String) throws {

		var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
									kSecUseDataProtectionKeychain as String: true,
									kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
									kSecAttrAccount as String: username,
									kSecAttrServer as String: server]

		if let securityGroup = keychainGroup {
			query[kSecAttrAccessGroup as String] = securityGroup
		}

		let secretData = token.data(using: String.Encoding.utf8)!
		query[kSecValueData as String] = secretData

		let status = SecItemAdd(query as CFDictionary, nil)

		switch status {
		case errSecSuccess:
			tokenDidChange(token)
			return
		case errSecDuplicateItem:
			break
		default:
			throw TokenManagerError.unhandledError(status: status)
		}
		
		var deleteQuery = query
		deleteQuery.removeValue(forKey: kSecAttrAccessible as String)
		SecItemDelete(deleteQuery as CFDictionary)
		
		let addStatus = SecItemAdd(query as CFDictionary, nil)
		if addStatus != errSecSuccess {
			throw TokenManagerError.unhandledError(status: status)
		}

		tokenDidChange(token)
	}
	
	static func retrieveToken(server: String, username: String) throws -> String? {
		
		var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
									kSecUseDataProtectionKeychain as String: true,
									kSecAttrAccount as String: username,
									kSecAttrServer as String: server,
									kSecMatchLimit as String: kSecMatchLimitOne,
									kSecReturnAttributes as String: true,
									kSecReturnData as String: true]
		
		if let securityGroup = keychainGroup {
			query[kSecAttrAccessGroup as String] = securityGroup
		}
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		
		guard status != errSecItemNotFound else {
			return nil
		}
		
		guard status == errSecSuccess else {
			throw TokenManagerError.unhandledError(status: status)
		}
		
		guard let existingItem = item as? [String : Any],
			let secretData = existingItem[kSecValueData as String] as? Data,
			let secret = String(data: secretData, encoding: String.Encoding.utf8) else {
				return nil
		}
		
		return secret
		
	}
	
	static func removeToken(server: String, username: String) throws {
		
		var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
									kSecUseDataProtectionKeychain as String: true,
									kSecAttrAccount as String: username,
									kSecAttrServer as String: server,
									kSecReturnAttributes as String: true,
									kSecReturnData as String: true]
		
		if let securityGroup = keychainGroup {
			query[kSecAttrAccessGroup as String] = securityGroup
		}
		
		let status = SecItemDelete(query as CFDictionary)
		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw TokenManagerError.unhandledError(status: status)
		}
		
		tokenDidChange(nil)
	}
	
	static func tokenDidChange(_ token: String?) {
		var userInfo = [AnyHashable: Any]()
		userInfo[Self.tokenUserInfoKey] = token
		NotificationCenter.default.post(name: .TokenDidChange, object: self, userInfo: userInfo)
	}

}
