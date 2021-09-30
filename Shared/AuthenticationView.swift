//
//  AuthenticationView.swift
//  Shared
//
//  Created by Maurice Parker on 9/30/21.
//

import SwiftUI

struct AuthenticationView: View {
	
	@StateObject private var viewModel = AuthenticationModel()

    var body: some View {
		VStack {
			Color.clear
			Form {
				Text("You need to sign in to use the Micro.blog Shortcut actions.\n\nEnter your Micro.blog email address. You'll receive an email with a link to confirm signing in.")
				emailTextField
				HStack {
					Spacer()
					Button("Sign In") {
						viewModel.requestUserLoginEmail()
					}
					Spacer()
				}
			}
			.frame(minWidth: 400, idealWidth: 400, maxWidth: 400, minHeight: 400)
			Color.clear
		}
    }
	
	@ViewBuilder var emailTextField: some View {
		#if os(iOS)
		TextField("Email", text: $viewModel.email)
			.disableAutocorrection(true)
			.autocapitalization(UITextAutocapitalizationType.none)
		#else
		TextField("Email", text: $viewModel.email)
			.disableAutocorrection(true)
			.padding()
		#endif
	}
	
}
