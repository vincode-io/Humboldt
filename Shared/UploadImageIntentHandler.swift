//
//  UploadImageIntentHandler.swift
//  Ringgold
//
//  Created by Maurice Parker on 10/7/21.
//

import Intents
import Snippets
import UIKit

public class UploadImageIntentHandler: NSObject, SnippetsIntentHandler, UploadImageIntentHandling {

	public func resolveBlogID(for intent: UploadImageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
		guard let blogID = intent.blogID else {
			completion(.notRequired())
			return
		}
		completion(.success(with: blogID))
	}
	
	public func resolveImage(for intent: UploadImageIntent, with completion: @escaping (UploadImageImageResolutionResult) -> Void) {
		guard let image = intent.image else {
			completion(.unsupported(forReason: .required))
			return
		}
		
		switch image.typeIdentifier {
		case "public.jpeg":
			break
		case "public.png":
			break
		default:
			completion(.unsupported(forReason: .invalidImageType))
			return
		}
		
		completion(.success(with: image))
	}
	
	public func handle(intent: UploadImageIntent, completion: @escaping (UploadImageIntentResponse) -> Void) {
		do {
			try configureSnippets(blogID: intent.blogID)
		} catch {
			completion(.init(code: .failure, userActivity: nil))
			return
		}
		
		guard let data = intent.image?.data, let image = UIImage(data: data) else {
			completion(.init(code: .failure, userActivity: nil))
			return
		}
		
		let imageType: SnippetsImageFileType = intent.image?.typeIdentifier == "public.jpeg" ? .jpeg : .png
		let snippetsImage = SnippetsImage(image, type: imageType)
		
		let _ = Snippets.shared.uploadImage(image: snippetsImage) { error, publishedPath in
			if error != nil {
				completion(.init(code: .failure, userActivity: nil))
				return
			}

			guard let publishedPath = publishedPath, let publishedURL = URL(string: publishedPath) else {
				completion(.init(code: .failure, userActivity: nil))
				return
			}
			
			let response = UploadImageIntentResponse(code: .success, userActivity: nil)
			response.publishedURL = publishedURL
			completion(response)
		}
	}
	
}
