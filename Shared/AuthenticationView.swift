//
//  AuthenticationView.swift
//  Shared
//
//  Created by Maurice Parker on 9/30/21.
//

import SwiftUI

struct AuthenticationView: View {
	
	@Environment(\.openURL) var openURL
	
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
					  dismissButton: Alert.Button.default(Text("Dismiss")) {
						viewModel.error = nil
				})
			}
			.alert(isPresented: $viewModel.showConfirmation) {
				Alert(title: Text("Request Sent"),
					  message: Text("Your email request has been sent. Check your email for the sign-in email."),
					  dismissButton: Alert.Button.default(Text("Great!")) {
						viewModel.error = nil
				})
			}
			.onChange(of: temporaryToken) { tempToken in
				viewModel.processTemporaryToken(tempToken)
				temporaryToken = ""
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
							#if canImport(UIKit)
							UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
							#endif
						}
						.keyboardShortcut(.defaultAction)
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
						shortcutsLink
						Spacer()
					}
					HStack {
						Spacer()
						Button("Sign Out") {
							viewModel.signOff()
						}
						Spacer()
					}
				}
				.frame(minWidth: 350, idealWidth: 350, maxWidth: 350, minHeight: 400)
				Color.clear
			}
		}
	}
	
	@ViewBuilder var emailTextField: some View {
		#if os(macOS)
		TextField("Email", text: $viewModel.email)
			.disableAutocorrection(true)
			.padding()
		#else
		TextField("Email", text: $viewModel.email)
			.disableAutocorrection(true)
			.keyboardType(.emailAddress)
			.autocapitalization(UITextAutocapitalizationType.none)
		#endif
	}
	
	@ViewBuilder var shortcutsLink: some View {
		#if os(macOS)
		Button("Open Shortcuts") {
			openURL(URL(string: "shortcuts://")!)
		}
		.keyboardShortcut(.defaultAction)
		.padding()
		#else
		Button("Open Shortcuts") {
			openURL(URL(string: "shortcuts://")!)
		}
		.keyboardShortcut(.defaultAction)
		#endif
	}
	
}
