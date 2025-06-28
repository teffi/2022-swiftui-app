//
//  ChangeMobileOTPScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/28/22.
//

import SwiftUI

struct ChangeMobileOTPScreen: View, OTPCompatible {
  @Environment(\.injected) private var dependencies
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject var profile: CreateProfileForm
  
  var token: String
  var salt: String
  var requestCodeData: OTP.Request?
  @State private var otpCode = ""
  @State private var isValid: Bool = false
  @State private var mobileUpdate: Loadable<Account.MobileUpdateResponse> = .idle
  @State private var isPresentingAlert = false
  @State private var alert: (title: String, message: String) = (title: "", message: "")
  
  var body: some View {
    ZStack {
      VStack {
        OTPView(code: $otpCode, isValid: $isValid, requestCodeData: requestCodeData)
      }
      buildMobileUpdate
        .alert(isPresented: $isPresentingAlert) {
          Alert(title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .cancel(Text("OK")))
        }
    }
    .onChange(of: isValid) { newValue in
      if isValid {
        verifyOTP()
      }
    }
    .navigationBarHidden(false)
    .navigationTitle("OTP")
    .navigationBarTitleDisplayMode(.inline)
  }
}
//  MARK: - View
extension ChangeMobileOTPScreen {
  @ViewBuilder var buildMobileUpdate: some View {
    switch mobileUpdate {
    case .idle:
      Color.clear
    case .loaded(let result):
      Color.clear.onAppear {
        dependencies.appState.userSession.token = result.appSessionToken
        profile.mobileNumber = requestCodeData?.mobileNumber ?? ""
        profile.mobileCountryCode = requestCodeData?.countryCode ?? ""
        presentation.wrappedValue.dismiss()
      }
    case .failed(let response):
      Color.clear.onAppear {
        let _ = print("failed account change mobile otp")
        showAlert(error: response)
      }
    case .isLoading(_, _):
      Color.black.opacity(0.02).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
}

//  MARK: - API
extension ChangeMobileOTPScreen {
  func verifyOTP() {
    guard let mobileData = requestCodeData else { return }
    dependencies.interactors.accountInteractor
      .updateMobile(userId: profile.userId,
                    mobileNumber: mobileData.mobileNumber,
                    countryCode: mobileData.countryCode,
                    otpCode: otpCode,
                    token: token,
                    salt: salt,
                    response: $mobileUpdate)
    
    print("account otp vertification")
  }
  
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
//  MARK: - Preview
struct ChangeMobileOTPScreen_Previews: PreviewProvider {
  static var previews: some View {
    ChangeMobileOTPScreen(token: "sample token", salt: "sample salt")
      .environmentObject(CreateProfileForm(profile: User.Profile.seed))
  }
}
