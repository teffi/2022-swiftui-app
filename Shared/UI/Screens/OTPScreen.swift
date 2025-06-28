//
//  OTPScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/22/22.
//

import SwiftUI
import Introspect
import Combine

struct OTPScreen: View {
  @Environment(\.injected) private var dependencies
  @Environment(\.presentationMode) private var presentation
  @StateObject private var model = OTPModel()
  @State private var otpText: String = ""
  @State private var verification: Loadable<Auth.Verification> = .idle
  @State private var otpCodeRequest: Loadable<Auth.OTP> = .idle
  @StateObject private var createProfile = CreateProfileForm()
  @State private var proceedToCreateProfile = false
  @State private var isPresentingAlert = false
  @State private var alert: (title: String, message: String) = (title: "", message: "")
  
  /// Token for verifying OTP.
  var token: String
  /// Salt for verifying OTP
  var salt: String
  /// Data that holds all the needed values to  request another code while on this screen.
  /// If nil, requesting will be disabled.
  var requestCodeData: OTPRequest?
  
  var body: some View {
    ZStack(alignment: .bottom) {
      buildVerification()
      content
      if requestCodeData != nil {
        footer
      }
      
      buildOTPCodeRequest
      
      NavigationLink(isActive: $proceedToCreateProfile) {
        CreateProfileScreen()
          .inject(dependencies)
          .environmentObject(createProfile)
      } label: { EmptyView() }
    }
    .navigationBarHidden(false)
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
  }
}
// MARK: - Views
extension OTPScreen {
  private var content: some View {
    VStack(alignment: .center, spacing: 30) {
      Text("You’ll receive a 6-digit code to verify\nyour number")
        .fontRegular(size: 16)
        .multilineTextAlignment(.center)
      HStack(spacing: 8) {
        otpTextDisplay(text: model.codes[safe: 0] ?? "")
        otpTextDisplay(text: model.codes[safe: 1] ?? "")
        otpTextDisplay(text: model.codes[safe: 2] ?? "")
        otpTextDisplay(text: model.codes[safe: 3] ?? "")
        otpTextDisplay(text: model.codes[safe: 4] ?? "")
        otpTextDisplay(text: model.codes[safe: 5] ?? "")
      }
      .overlay(alignment: .bottom, content: {
        TextField("", text: $model.otpCode)
          .frame(maxHeight: .infinity)
          .textContentType(.oneTimeCode)
          .accentColor(Color.clear)
          .foregroundColor(Color.clear)
          .background(Color.clear)
          .keyboardType(.numberPad)
          //  Limit text to 5 characters. This is called multiple times
          .onReceive(Just(model.otpCode)) { inputValue in
            if inputValue.count > model.limit {
              model.otpCode = inputValue[0..<model.limit]
            }
          }
      })
      .alert(isPresented: $isPresentingAlert) {
        Alert(title: Text(alert.title),
              message: Text(alert.message),
              dismissButton: .cancel(Text("OK")))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .introspectTextField { field in
      //  Note: This causes the bottom whitespace on preview which is where the keyboard is
      // TODO: This triggers previous screen to rerender the navigation link
      field.becomeFirstResponder()
    }

    //  Subscribe to otp validity
    .onChange(of: model.isValid) { isValid in
      if isValid == true {
        verifyOTP()
      } else {
        // Do nothing!
        print("value is invalid: \(model.otpCode)")
      }
    }
 
  }
  
  private var footer: some View {
    VStack(spacing: 0) {
      Text("Didn't receive code?")
        .fontRegular(size: 12)
      Button("Request again") {
        if let data = requestCodeData {
          requestOTP(with: data)
        }
      }
      .buttonStyle(.plain)
      .fontHeavy(size: 16)
      .fgAssetColor(.purple)
      .padding(10)
    }
    .padding(.bottom, 20)
  }
  
  private func otpTextDisplay(text: String) -> some View {
    Text(text)
      .frame(width: 44, height: 44)
      .fgAssetColor(.black)
      .fontRegular(size: 16)
      .bgAssetColor(.gray_1)
      .multilineTextAlignment(.center)
      .lineLimit(1)
      .cornerRadius(8)
      .fixedSize()
  }
  
  @ViewBuilder func buildVerification() -> some View {
    switch verification {
    case .idle:
      Color.clear
    case .loaded(let result):
      Color.clear.onAppear {
        if result.newUser {
          createProfile.userId = result.user.id
          proceedToCreateProfile = true
        } else {
          dependencies.appState.updateRoot(.tab)
        }
      }
    case .failed(let response):
      Color.clear.onAppear {
        showAlert(error: response)
        otpText = ""
      }
    case .isLoading(_, _):
      Color.black.opacity(0.02).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
  
  @ViewBuilder private var buildOTPCodeRequest: some View {
    switch otpCodeRequest {
    case .loaded(_):
      Color.clear.onAppear {
        alert = (title: "Sent", message: "You'll receive your new 6 digit code shortly.")
        isPresentingAlert = true
      }
    case .failed(let response):
      Color.clear.onAppear {
        showAlert(error: response)
      }
    default:
      Color.clear
    }
  }
}

extension OTPScreen {
  func showAlert(error: Error) {
    var alertTitle = "Something went wrong"
    var alertMessage = error.localizedDescription
    if let err = error.asAPIError {
      alertTitle = err.alert.title
      alertMessage = err.alert.message
    }
    alert = (title: alertTitle, message: alertMessage)
    isPresentingAlert = true
  }
}

// MARK: - API
extension OTPScreen {
  func verifyOTP() {
    dependencies.interactors.authInteractor.verifyOTP(code: model.otpCode,
                                                      token: token,
                                                      salt: salt,
                                                      response: $verification)
  }
  
  func requestOTP(with data: OTPRequest) {
    dependencies.interactors
      .authInteractor
      .requestOTP(mobileNumber: data.mobileNumber,
                  countryCode: data.countryCode,
                  mode: data.mode,
                  userId: data.userId,
                  inviteCode: data.inviteCode,
                  response: $otpCodeRequest)
  }
}

// MARK: - Models
extension OTPScreen {
  struct OTPRequest {
    let mobileNumber: String
    let countryCode: String
    let userId: String?
    let inviteCode: String?
    let mode: AuthInteractor.OTPOrigin
  }
  
  enum NextScreen {
    case feed
    case createProfile
  }
}

//  MARK: - Preview
struct OTPScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      //OTPScreen(token: "preview_token", salt: "preview_salt")
      OTPScreen(token: "preview_token", salt: "preview_salt", requestCodeData: .init(mobileNumber: "1231", countryCode: "+123", userId: nil, inviteCode: nil, mode: .signup))
    }
  }
}
