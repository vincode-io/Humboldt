//
//  PostHTMLIntentHandler.swift
//  Ringgold
//
//  Created by Maurice Parker on 10/6/21.
//

import Intents
import Snippets
import UIKit

enum PostHTMLIntentHandlerError: LocalizedError {
	case tokenRequired
	case unableToFetchUserConfiguation
	
	public var errorDescription: String? {
		switch self {
			
		case .tokenRequired:
			return NSLocalizedString("You must be signed into the main Ringgold app to use Shortcuts.", comment: "Token required")
		case .unableToFetchUserConfiguation:
			return NSLocalizedString("Unable to fetch blog id. Please try again later.", comment: "Unable to fetch blog id")
		}
	}
	
}

public class PostHTMLIntentHandler: NSObject, PostHTMLIntentHandling {
	
	public func provideBlogIDOptionsCollection(for intent: PostHTMLIntent, with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void) {
		do {
			try configureSnippets()
		} catch {
			completion(nil, error)
			return
		}
		
		Snippets.Microblog.fetchCurrentUserConfiguration { error, result in
			if let error = error {
				completion(nil, error)
				return
			}
			
			guard let destinations = result["destination"] as? [[String: Any]] else {
				completion(nil, PostHTMLIntentHandlerError.unableToFetchUserConfiguation)
				return
			}
			
			let blogIDs = destinations.compactMap { $0["uid"] as? NSString }
			let inCollection = INObjectCollection(items: blogIDs)
			completion(inCollection, nil)
		}
	}
	
	public func resolveBlogID(for intent: PostHTMLIntent, with completion: @escaping (PostHTMLBlogIDResolutionResult) -> Void) {
		if let blogID = intent.blogID {
			completion(.success(with: blogID))
			return
		}
		
		do {
			try configureSnippets()
		} catch {
			completion(.unsupported(forReason: .tokenRequired))
			return
		}

		Snippets.Microblog.fetchCurrentUserConfiguration { error, result in
			if error != nil {
				completion(.unsupported(forReason: .unableToFetchBlogID))
				return
			}
			
			guard let destinations = result["destination"] as? [[String: Any]] else {
				completion(.unsupported(forReason: .unableToFetchBlogID))
				return
			}
			
			guard let blogID = destinations.first(where: { $0["microblog-default"] as! Bool })?["uid"] as? String else {
				completion(.unsupported(forReason: .unableToFetchBlogID))
				return
			}
			completion(.success(with: blogID))
		}
	}

	public func resolveTitle(for intent: PostHTMLIntent, with completion: @escaping (PostHTMLTitleResolutionResult) -> Void) {
		completion(.success(with: intent.title ?? ""))
	}

	public func resolveHtml(for intent: PostHTMLIntent, with completion: @escaping (PostHTMLHtmlResolutionResult) -> Void) {
		guard let html = intent.html else {
			completion(.unsupported(forReason: .required))
			return
		}
		completion(.success(with: html))
	}
	
	public func handle(intent: PostHTMLIntent, completion: @escaping (PostHTMLIntentResponse) -> Void) {
		do {
			try configureSnippets(blogID: intent.blogID)
		} catch {
			completion(.init(code: .failure, userActivity: nil))
			return
		}

		let _ = Snippets.shared.postHtml(title: intent.title ?? "", content: intent.html ?? "") { error, location in
			if error != nil {
				completion(.init(code: .failure, userActivity: nil))
				return
			}
			
			let response = PostHTMLIntentResponse()
			response.location = location
			completion(response)
		}
	}
	
}

private extension PostHTMLIntentHandler {
	
	func configureSnippets(blogID: String? = nil) throws {
		guard let token = try? TokenManager.retrieveToken() else {
			throw PostHTMLIntentHandlerError.tokenRequired
		}
		let config = Snippets.Configuration.microblogConfiguration(token: token, uid: blogID)
		Snippets.Configuration.timeline = config
		Snippets.Configuration.publishing = config
	}
	
}
