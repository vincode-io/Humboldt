//
//  AppDelegate.swift
//  Ringgold (macOS)
//
//  Created by Maurice Parker on 9/30/21.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

	override init() {
		NSWindow.allowsAutomaticWindowTabbing
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		let mainMenu = NSApplication.shared.mainMenu!
		for i in 1..<mainMenu.numberOfItems {
			mainMenu.removeItem(at: i)
		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
}
