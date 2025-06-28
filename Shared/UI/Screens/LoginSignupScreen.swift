//
//  LoginSignupScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/18/22.
//

import SwiftUI
import BetterSafariView
import AuthenticationServices

struct LoginSignupScreen: View {
  @Environment(\.loginSignupActivity) var activity
  @Environment(\.injected) var dependencies
  //  Mobile
  @State private var mobileNumber = ""
  @State private var country = CountryCodeList.deviceLocale
  @State private var showCountryList = false
  //  OTP
  @State private var otp: Loadable<Auth.OTP> = .idle
  @State private var requestCodeData: OTPScreen.OTPRequest?
  
  //@State private var showCredentialRawText = false
  //  Sign in with Apple
  @State private var verifyApple: Loadable<Auth.Verification> = .idle
  
  // Create profile
  @StateObject private var profileForm = CreateProfileForm()
  
  //  Destination
  @State private var destination: LoginSignupScreen.Destination?
  
  //  Safari
  @State private var isPresentedTerms = false
  @State private var isPresentedPrivacy = false
  private var termsURL = URL(string: "https://dash.staging-dash.com/terms")!
  private var privacyURL = URL(string: "https://dash.staging-dash.com/privacy")!

  private var oppositeActivity: LoginSignupActivityKey.Activity {
    switch activity {
    case .login:
      return .signup(inviteCode: "")
    default:
      return .login
    }
  }
  
  private var isSigningUp: Bool {
    switch activity {
    case .signup:
      return true
    default:
      return false
    }
  }
  
  private var appleCredential: Auth.AppleCredential? {
    DefaultStore.decode(key: .apple_credentials, type: Auth.AppleCredential.self)
  }
  
  var body: some View {
    ZStack {
      buildOTPRequest()
      buildVerifyApple()
      VStack {
        Spacer()
        mobileView
        Text("or")
          .padding()
          .fontRegular(size: 16)
        signInWithApple
          .padding(.bottom, 24)
        
        if isSigningUp {
          agreementText
        }
        Spacer()
      }
      .padding(.horizontal, 20)
      
      /** Bottom Content */
      VStack {
        Spacer()
        footer
      }.ignoresSafeArea(.keyboard)
      
      //  Navigation Links
      NavigationLink(tag: .otp, selection: $destination) {
        let _ = print("nav link: otp  is called")
        if let otpData = otp.value {
          OTPScreen(token: otpData.userToken,
                    salt: otpData.authSalt,
                    requestCodeData: requestCodeData)
        }
      } label: { EmptyView() }

      NavigationLink(tag: .create_profile, selection: $destination) {
        CreateProfileScreen()
          .environmentObject(profileForm)
      } label: { EmptyView()}
      
      //  Hack for iOS 14.5
      //  Issue: SwiftUI NavigationLink pops out by itself
      //  Cause: Happening in places where there's multiple navigation link
      //  https://developer.apple.com/forums/thread/677333
      NavigationLink(destination: EmptyView()) {
        EmptyView()
      }
      
    }
    .safariView(isPresented: $isPresentedTerms) {
      safariView(url: termsURL)
    }
    
    .safariView(isPresented: $isPresentedPrivacy) {
      safariView(url: privacyURL)
    }
  
    .navigationTitle(activity.label)
    .navigationBarTitleDisplayMode(.large)
    .navigationBarBackButtonHidden(true)
  }
  
}

//  MARK: - Views
extension LoginSignupScreen {
  @ViewBuilder private var mobileView: some View {
    VStack(alignment: .leading, spacing: 16) {
      mobileField
      Button(activity.label) {
        KeyboardResponder.dismiss()
        requestOTP()
      }
      .appButtonStyle(.primaryFullWidth)
    }
  }
  
  private var mobileField: some View {
    HStack(spacing: 16) {
      countryCodeView
        .overlay(Divider().padding(.vertical, 6), alignment: .trailing)
      
      TextField("Mobile number", text: $mobileNumber)
        .fontRegular(size: 16)
        .fgAssetColor(.black)
        .keyboardType(.numberPad)
    }
    .bgAssetColor(.gray_1)
    .cornerRadius(8)
  }
  
  private var countryCodeView: some View {
    Button {
      showCountryList.toggle()
    } label: {
      Text(country.phoneCodeWithSymbol)
        .fontRegular(size: 16)
        .fgAssetColor(.black)
        .padding(.trailing, 20)
        .overlay(alignment: .bottomTrailing) {
          Image(systemName: "chevron.down")
            .imageScale(.small)
            .frame(maxHeight: .infinity)
            .fgAssetColor(.black)
            .offset(x: 5)
        }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .sheet(isPresented: $showCountryList) {
      CountryCodeList(selectedCountry: $country)
    }
  }
  
  @ViewBuilder private var footer: some View {
    VStack(spacing: 8) {
      oppositeActivityText
      oppositeActivityButton
    }
  }
  
  private var oppositeActivityText: some View {
    Text(isSigningUp ? "Already have an account?" : "Don't have an account yet?")
      .fontRegular(size: 16)
      .fgAssetColor(.black)
  }
  
  private var oppositeActivityButton: some View {
    Button(oppositeActivity.label) {
      switch oppositeActivity {
      case .login:
        dependencies.appState.routeEntryTo(.login)
      case .signup:
        dependencies.appState.routeEntryTo(.signup)
      }
    }
    .appButtonStyle(.primaryText)
  }
  
  private var agreementText: some View {
    VStack(spacing: 8) {
      Text("By signing up, you agree to our")
        .fontRegular(size: 11.5)
        .fgAssetColor(.black)
      Text("Terms & Conditions")
        .fontRegular(size: 11.5)
        .fgAssetColor(.purple)
        .onTapGesture {
          isPresentedTerms = true
        }
      Text("and")
        .fontRegular(size: 11.5)
        .fgAssetColor(.black)
      Text("Privacy Policy")
        .fontRegular(size: 11.5)
        .fgAssetColor(.purple)
        .onTapGesture {
          isPresentedPrivacy = true
        }
    }
  }
  
  private var signInWithApple: some View {
    //  TODO: Move this to auth interactor with publisher.
    SignInWithAppleButton(isSigningUp ? .continue : .signIn) { request in
      request.requestedScopes = [.fullName, .email]
    } onCompletion: { result in
      switch result {
      case .success(let authorization):
        //  Save credential to userdefaults
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let data = credential.credentialData {
          DefaultStore.save(.apple_credentials, value: data)
          
          //  Verify with our api
          if let authCode = credential.authorizationCodeString,
             let token = credential.idToken {
            verifySignInWithApple(code: authCode, token: token, email: credential.availableEmail)
          } else {
            print("missing authorization code or id token, cant continue to verify sign in with apple")
          }
        }
      case .failure(let error):
        print("Authorisation failed: \(error.localizedDescription)")
      }
    }
    .frame(height: 47)
    .signInWithAppleButtonStyle(.black)
  }
  
  private func safariView(url: URL) -> SafariView {
    SafariView(
      url: url,
      configuration: SafariView.Configuration(entersReaderIfAvailable: false, barCollapsingEnabled: true)
    )
      .preferredBarAccentColor(.clear)
      .preferredControlAccentColor(.accentColor)
      .dismissButtonStyle(.done)
  }
  
  @ViewBuilder func buildOTPRequest() -> some View {
    switch otp {
    case .idle:
      Color.clear
    case .loaded:
      Color.clear.onAppear {
        destination = .otp
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
  
  
  @ViewBuilder func buildVerifyApple() -> some View {
    switch verifyApple {
    case .idle:
      Color.clear
    case .loaded(let result):
      Color.clear.onAppear {
        if result.newUser {
          if let appleUser = DefaultStore.decode(key: .apple_credentials, type: Auth.AppleCredential.self) {
            profileForm.firstName = appleUser.firstName ?? ""
            profileForm.lastName = appleUser.lastName ?? ""
          }
          profileForm.userId = result.user.id
          destination = .create_profile
        } else {
          dependencies.appState.updateRoot(.tab)
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
extension LoginSignupScreen {
  func requestOTP() {
    var mode: AuthInteractor.OTPOrigin
    var _inviteCode: String?
    switch activity {
    case .signup(let inviteCode):
      mode = .signup
      _inviteCode = inviteCode
    case .login:
      mode = .login
    }
    
    requestCodeData = .init(mobileNumber: mobileNumber,
                            countryCode: country.phoneCodeWithSymbol,
                            userId: nil,
                            inviteCode: _inviteCode,
                            mode: mode)
    dependencies.interactors
      .authInteractor
      .requestOTP(mobileNumber: mobileNumber,
                  countryCode: country.phoneCodeWithSymbol,
                  mode: mode,
                  userId: nil,
                  inviteCode: _inviteCode,
                  response: $otp)
  }
  
  func verifySignInWithApple(code: String, token: String, email: String?) {
    var mode: AuthInteractor.OTPOrigin
    var _inviteCode: String?
    switch activity {
    case .signup(let inviteCode):
      mode = .signup
      _inviteCode = inviteCode
    case .login:
      mode = .login
    }
    
    dependencies.interactors
      .authInteractor
      .verifySignInWithApple(code: code,
                             idToken: token,
                             mode: mode,
                             inviteCode: _inviteCode,
                             userEmail: email,
                             response: $verifyApple)
  }
}

//  MARK: - Model and Enums
extension LoginSignupScreen {
  enum Destination {
    case otp, create_profile
  }
}
//  MARK: - Previews
struct LoginSignupScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      LoginSignupScreen()
        .environment(\.loginSignupActivity, .signup(inviteCode: "preview_invite_code"))
    }
  }
}

//  MARK: - Environment
struct LoginSignupActivityKey: EnvironmentKey {
  static var defaultValue: Activity = .login
  enum Activity {
    case login
    case signup(inviteCode: String)
    
    var label: String {
      switch self {
      case .login:
        return "Sign in"
      case .signup:
        return "Create account"
      }
    }
  }
}
//  MARK: Values
extension EnvironmentValues {
  var loginSignupActivity: LoginSignupActivityKey.Activity {
    get { self[LoginSignupActivityKey.self] }
    set { self[LoginSignupActivityKey.self] = newValue }
  }
}

extension ASAuthorizationAppleIDCredential {
  var firstName: String {
    return fullName?.givenName ?? ""
  }
  
  var lastName: String {
    return fullName?.familyName ?? ""
  }
  
  var idToken: String? {
    guard let token = identityToken else {
      print("Unable to fetch identity token")
      return nil
    }
    
    guard let tokenString = String(data: token, encoding: .utf8) else {
      print("Unable to serialize token string from data: \(token.debugDescription)")
      return nil
    }
    
    return tokenString
  }
  
  var authorizationCodeString: String? {
    guard let code = authorizationCode else {
      print("Unable to fetch authorization code")
      return nil
    }
    
    guard let codeString = String(data: code, encoding: .utf8) else {
      print("Unable to serialize token string from data: \(code.debugDescription)")
      return nil
    }
    
    return codeString
  }
  
  var credentialData: Data? {
    let encoder = JSONEncoder()
    do {
      return try encoder.encode(Auth.AppleCredential(idToken: idToken ?? "",
                                                     userId: user,
                                                     firstName: firstName,
                                                     lastName: lastName,
                                                     email: email ?? "",
                                                     authCode: authorizationCodeString ?? ""))
    } catch {
      print("Unable to encode credentials to AppleCredential")
    }
    return nil
  }
  
  /// Returns `email` from credential instance or  email from in `DefaultStore`.
  var availableEmail: String? {
    let storedCredential = DefaultStore.decode(key: .apple_credentials, type: Auth.AppleCredential.self)
    print("authorisation_code: \(storedCredential?.authCode)\n\n\nid_token:\(storedCredential?.idToken)\n\n\nuser_identifier:\(storedCredential?.userId)\n\n\nname:\(storedCredential?.firstName) \(storedCredential?.lastName)\n\n\nemail: \(storedCredential?.email)")
    return email ?? storedCredential?.email
  }
}

