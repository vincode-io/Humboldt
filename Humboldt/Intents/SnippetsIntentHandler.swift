//
//  SnippetsIntentHandler.swift
//  Humboldt
//
//  Created by Maurice Parker on 10/7/21.
//

import Intents
import Snippets

enum SnippetsIntentHandlerError: LocalizedError {
	case tokenRequired
	case unableToFetchUserConfiguation
	
	public var errorDescription: String? {
		switch self {
			
		case .tokenRequired:
			return NSLocalizedString("You must be signed into the main Humboldt app to use Shortcuts.", comment: "Token required")
		case .unableToFetchUserConfiguation:
			return NSLocalizedString("Unable to fetch blog id. Please try again later.", comment: "Unable to fetch blog id")
		}
	}
	
}

protocol SnippetsIntentHandler {
	
}

extension SnippetsIntentHandler {
	
	func configureSnippets(blogID: String? = nil) throws {
		guard let token = try? TokenManager.retrieveToken() else {
			throw SnippetsIntentHandlerError.tokenRequired
		}
		let config = Snippets.Configuration.microblogConfiguration(token: token, uid: blogID)
		Snippets.Configuration.timeline = config
		Snippets.Configuration.publishing = config
	}
	
}
