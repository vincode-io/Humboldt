//
//  RinggoldApp.swift
//  Shared
//
//  Created by Maurice Parker on 9/30/21.
//

import SwiftUI

@main
struct RinggoldApp: App {
	
	#if os(macOS)
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
	#endif

	@State var temporaryToken: String = ""
	
	let frameWidth: CGFloat = 500
	let frameHeight: CGFloat = 400

    var body: some Scene {
		#if os(macOS)
        WindowGroup {
            AuthenticationView(temporaryToken: $temporaryToken)
				.frame(minWidth: frameWidth, idealWidth: frameWidth, maxWidth: frameWidth, minHeight: frameHeight, idealHeight: frameHeight, maxHeight: frameHeight)
				.onOpenURL { url in
					handle(url: url)
				}
        }
		#else
		WindowGroup {
			AuthenticationView(temporaryToken: $temporaryToken)
				.onOpenURL { url in
					handle(url: url)
				}
		}
		#endif
    }
	
}

private extension RinggoldApp {
	
	func handle(url: URL) {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let token = components.queryItems?.first?.value else {
			return
		}
		temporaryToken = token
	}
	
}
