//
//  AppDelegate.swift
//  Ringgold (macOS)
//
//  Created by Maurice Parker on 9/30/21.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
}
