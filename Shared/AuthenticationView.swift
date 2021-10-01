//
//  AuthenticationView.swift
//  Shared
//
//  Created by Maurice Parker on 9/30/21.
//

import SwiftUI

struct AuthenticationView: View {
	
	@Binding var temporaryToken: String
	@StateObject private var viewModel = AuthenticationModel()

	var body: some View {
		mainContent
			.onAppear {
				viewModel.start()
			}
			.alert(isPresented: $viewModel.showError) {
				Alert(title: Text("Error"),
					  message: Text(viewModel.error!.localizedDescription),
					  dismissButton: Alert.Button.cancel({
						viewModel.error = nil
				}))
			}
			.onChange(of: temporaryToken) { tempToken in
				viewModel.processTemporaryToken(tempToken)
			}
	}
	
	@ViewBuilder var mainContent: some View {
		if !viewModel.authenticated {
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
		} else {
			VStack {
				Color.clear
				Form {
					Text("You have been authenticated and are ready to run Micro.blog Shortcuts.")
					HStack {
						Spacer()
						Button("Sign Out") {
							viewModel.signOff()
						}
						Spacer()
					}
				}
				.frame(minWidth: 400, idealWidth: 400, maxWidth: 400, minHeight: 400)
				Color.clear
			}
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
