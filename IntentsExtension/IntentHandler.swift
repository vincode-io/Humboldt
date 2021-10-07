//
//  IntentHandler.swift
//  IntentsExtension
//
//  Created by Maurice Parker on 10/1/21.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
		switch intent {
		case is GetBlogIDIntent:
			return GetBlogIDIntentHandler()
		case is PostHTMLIntent:
			return PostHTMLIntentHandler()
		case is UploadImageIntent:
			return UploadImageIntentHandler()
		default:
			fatalError("Unrecognized Intent")
		}
    }
    
}
