//
//  InviteCodeScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/23/22.
//

import SwiftUI

struct InviteCodeScreen: View {
  @Environment(\.injected) var dependencies: DIContainer
  @StateObject private var keyboard = KeyboardResponder()
  @State private var inviteCode = ""
  @State private var verification: Loadable<Response> = .idle
  @State private var proceedToSignup = false
  @State private var enableTextEditing = false
  
  var body: some View {
    ZStack {
      VStack(alignment: .leading, spacing: 30) {
        header
        textField
        note
        continueButton
        Spacer()
        
        NavigationLink(isActive: $proceedToSignup) {
          LoginSignupScreen()
            .environment(\.loginSignupActivity, .signup(inviteCode: inviteCode))
        } label: {
          EmptyView()
        }
        
        NavigationLink(destination: EmptyView()) {
          EmptyView()
        }
        
      }
      .padding(.horizontal, 24)
      
      buildVerification()
    }
   
    .navigationBarHidden(false)
  }
}
//  MARK: - Views
extension InviteCodeScreen {
  private var continueButton: some View {
    Button("Continue") {
      submit()
    }
    .appButtonStyle(.primaryFullWidth)
  }
  
  private var textField: some View {
    TextField("Enter invite code", text: $inviteCode)
      .fontRegular(size: 16)
      .frame(width: 200)
      .fgAssetColor(.black)
      .keyboardType(.numberPad)
      .padding(12)
      .bgAssetColor(.gray_1)
      .cornerRadius(8)
  }
  
  private var header: some View {
    Text("To continue please enter your invite code")
      .fontBold(size: 20)
      .fgAssetColor(.black)
  }
  
  private var note: some View {
    RichText("We’re currently on beta phase and can only access the app through invite code\n\nTo request for an invite, send us an email to **help@dash.com**")
      .fontSemibold(size: 11.5)
      .fgAssetColor(.black)
  }

  @ViewBuilder func buildVerification() -> some View {
    switch verification {
    case .idle:
      Color.clear
    case .loaded(let result):
      Color.clear.onAppear {
        //  If there's no error in success, update route.
        if result.error == nil {
          proceedToSignup = true
        }
      }
    case .failed(let response):
      Color.clear.onAppear {
        var alertTitle = "Something went wrong"
        var alertMessage = response.localizedDescription
        if let err = response.asAPIError {
          alertTitle = err.alert.title
          alertMessage = err.alert.message
        }
        dependencies.appState.showAlert(title: alertTitle,
                                        message: alertMessage)
      }
    case .isLoading(_, _):
      Color.black.opacity(0.05).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
}

//  MARK: - API
extension InviteCodeScreen {
  func submit() {
    dependencies.interactors.authInteractor.verifyInvite(code: inviteCode,
                                                         response: $verification)
  }
}

struct InviteCodeScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      InviteCodeScreen()
    }
  }
}

