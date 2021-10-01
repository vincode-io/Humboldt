//
//  IntentHandler.swift
//

import Intents

class IntentHandler: INExtension {
    
	override func handler(for intent: INIntent) -> Any {
		switch intent {
//		case is AddWebFeedIntent:
//			return AddWebFeedIntentHandler()
		default:
			fatalError("Unhandled intent type: \(intent)")
		}
	}
    
}
