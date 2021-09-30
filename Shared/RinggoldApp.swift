//
//  RinggoldApp.swift
//  Shared
//
//  Created by Maurice Parker on 9/30/21.
//

import SwiftUI

@main
struct RinggoldApp: App {
    var body: some Scene {
		#if os(macOS)
        WindowGroup {
            ContentView()
				.frame(minWidth: 400, idealWidth: 400, maxWidth: 400, minHeight: 400, idealHeight: 400, maxHeight: 400)
        }
		#else
		WindowGroup {
			ContentView()
		}
		#endif
    }
}
