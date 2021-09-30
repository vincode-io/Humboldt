//
//  RinggoldApp.swift
//  Shared
//
//  Created by Maurice Parker on 9/30/21.
//

import SwiftUI

@main
struct RinggoldApp: App {
	
	let frameWidth: CGFloat = 400
	let frameHeight: CGFloat = 400

    var body: some Scene {
		#if os(macOS)
        WindowGroup {
            ContentView()
				.frame(minWidth: frameWidth, idealWidth: frameWidth, maxWidth: frameWidth, minHeight: frameHeight, idealHeight: frameHeight, maxHeight: frameHeight)
				.onOpenURL { url in
					handle(url: url)
				}
        }
		#else
		WindowGroup {
			ContentView()
				.onOpenURL { url in
					handle(url: url)
				}
		}
		#endif
    }
	
}

private extension RinggoldApp {
	
	func handle(url: URL) {
		
	}
	
}
