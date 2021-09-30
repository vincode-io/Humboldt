//
//  CredentialsManager.swift
//  Ringgold
//
//  Created by Maurice Parker on 9/30/21.
//

import Foundation

public enum CredentialsManagerError: Error {
	case unhandledError(status: OSStatus)
}

public struct CredentialsManager {
	
	private static var keychainGroup: String? = {
		guard let appGroup = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as? String else {
			return nil
		}
		let appIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as! String
		let appGroupSuffix = appGroup.suffix(appGroup.count - 6)
		return "\(appIdentifierPrefix)\(appGroupSuffix)"
	}()

	public static func storeToken(_ token: String, server: String, username: String) throws {

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
			return
		case errSecDuplicateItem:
			break
		default:
			throw CredentialsManagerError.unhandledError(status: status)
		}
		
		var deleteQuery = query
		deleteQuery.removeValue(forKey: kSecAttrAccessible as String)
		SecItemDelete(deleteQuery as CFDictionary)
		
		let addStatus = SecItemAdd(query as CFDictionary, nil)
		if addStatus != errSecSuccess {
			throw CredentialsManagerError.unhandledError(status: status)
		}

	}
	
	public static func retrieveToken(server: String, username: String) throws -> String? {
		
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
			throw CredentialsManagerError.unhandledError(status: status)
		}
		
		guard let existingItem = item as? [String : Any],
			let secretData = existingItem[kSecValueData as String] as? Data,
			let secret = String(data: secretData, encoding: String.Encoding.utf8) else {
				return nil
		}
		
		return secret
		
	}
	
	public static func removeToken(_ token: String, server: String, username: String) throws {
		
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
		
		let status = SecItemDelete(query as CFDictionary)
		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw CredentialsManagerError.unhandledError(status: status)
		}
		
	}
	
}
