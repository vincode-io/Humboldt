//
//  GetBlogIDIntentHandler.swift
//  Ringgold
//
//  Created by Maurice Parker on 10/7/21.
//

import Intents
import Snippets

public class GetBlogIDIntentHandler: NSObject, SnippetsIntentHandler, GetBlogIDIntentHandling {
	
	public func provideBlogIDOptionsCollection(for intent: GetBlogIDIntent, with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void) {
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
				completion(nil, SnippetsIntentHandlerError.unableToFetchUserConfiguation)
				return
			}
			
			let blogIDs = destinations.compactMap { $0["uid"] as? NSString }
			let inCollection = INObjectCollection(items: blogIDs)
			completion(inCollection, nil)
		}
	}
	
	public func resolveBlogID(for intent: GetBlogIDIntent, with completion: @escaping (GetBlogIDBlogIDResolutionResult) -> Void) {
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
	
	public func handle(intent: GetBlogIDIntent, completion: @escaping (GetBlogIDIntentResponse) -> Void) {
		let response = GetBlogIDIntentResponse()
		response.blogID = intent.blogID
		completion(response)
	}
	
}
