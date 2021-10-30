//
//  PostHTMLIntentHandler.swift
//  Humboldt
//
//  Created by Maurice Parker on 10/6/21.
//

import Intents
import Snippets
import UIKit

public class PostHTMLIntentHandler: NSObject, SnippetsIntentHandler, PostHTMLIntentHandling {

	public func resolveBlogID(for intent: PostHTMLIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
		guard let blogID = intent.blogID else {
			completion(.notRequired())
			return
		}
		completion(.success(with: blogID))
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
			completion(.init(code: .tokenRequired, userActivity: nil))
			return
		}

		let _ = Snippets.shared.postHtml(title: intent.title ?? "", content: intent.html ?? "") { error, location in
			if error != nil {
				completion(.init(code: .failure, userActivity: nil))
				return
			}

			guard let publishedPath = location, let publishedURL = URL(string: publishedPath) else {
				completion(.init(code: .failure, userActivity: nil))
				return
			}

			let response = PostHTMLIntentResponse(code: .success, userActivity: nil)
			response.publishedURL = publishedURL
			completion(response)
		}
	}
	
}
