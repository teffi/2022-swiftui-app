//
//  AuthInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 2/23/22.
//

import Foundation

protocol AuthInteractable {
  func verifyInvite(code: String, response: LoadableSubject<Response>)
  func requestOTP(mobileNumber: String,
                  countryCode: String,
                  mode: AuthInteractor.OTPOrigin,
                  userId: String?,
                  inviteCode: String?,
                  response: LoadableSubject<Auth.OTP>)
  func verifyOTP(code: String,
                 token: String,
                 salt: String,
                 response: LoadableSubject<Auth.Verification>)
  func verifySignInWithApple(code: String,
                             idToken: String,
                             mode: AuthInteractor.OTPOrigin,
                             inviteCode: String?,
                             userEmail: String?,
                             response: LoadableSubject<Auth.Verification>)
}

struct AuthInteractor: AuthInteractable {
  let appState: AppState
  let api: AuthAPI
  
  func verifyInvite(code: String, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.verifyInviteCode(body: ["invite_code": code])
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func requestOTP(mobileNumber: String,
                  countryCode: String,
                  mode: OTPOrigin,
                  userId: String?,
                  inviteCode: String?,
                  response: LoadableSubject<Auth.OTP>) {
    
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    // Compose body
    var body: [String: Any] = ["mobile_number": mobileNumber,
                               "mobile_country_code": countryCode,
                               "mode": mode.rawValue]
    if let userId = userId {
      body["user_id"] = userId
    }
    if let inviteCode = inviteCode {
      body["invite_code"] = inviteCode
    }
    api.requestOTP(body: body)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func verifyOTP(code: String,
                 token: String,
                 salt: String,
                 response: LoadableSubject<Auth.Verification>) {
    
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.verifyOTP(body:  ["otp": code,
                          "auth_salt": salt,
                          "user_token": token])
      .sinkToLoadable { result in
        response.wrappedValue = result
        
        //   UPDATE app state user and session
        let _ = result.map { verification in
          appState.updateSession(.init(token: verification.appSessionToken,
                                       userId: verification.user.id,
                                       displayName: verification.user.displayName,
                                       fullName: verification.user.fullName ?? verification.user.displayName,
                                       profileImage: verification.user.profileImage))
        }
      }
      .store(in: cancelBag)
  }
  
  func verifySignInWithApple(code: String,
                             idToken: String,
                             mode: OTPOrigin,
                             inviteCode: String?,
                             userEmail: String?,
                             response: LoadableSubject<Auth.Verification>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    var body = ["code": code,
                "id_token": idToken,
                "mode": mode.rawValue]
    
    if let inviteCode = inviteCode {
      body["invite_code"] = inviteCode
    }
    
    if let email = userEmail {
      body["apple_email"] = email
    }
    
    api.verifySignInWithApple(body: body)
      .sinkToLoadable { result in
        response.wrappedValue = result
        
        //   UPDATE app state user and session
        let _ = result.map { verification in
          appState.updateSession(.init(token: verification.appSessionToken,
                                       userId: verification.user.id,
                                       displayName: verification.user.displayName,
                                       fullName: verification.user.fullName ?? verification.user.displayName,
                                       profileImage: verification.user.profileImage))
        }
      }
      .store(in: cancelBag)
  }
}

extension AuthInteractor {
  enum OTPOrigin: String {
    case signup = "signup"
    case login = "login"
    case changeMobile = "change_mobile"
  }
  
  /// Request otp mirror without  the optional parameters
  /// - Parameters:
  ///   - mobileNumber:
  ///   - countryCode:
  ///   - mode:
  func requestOTP(mobileNumber: String, countryCode: String, mode: OTPOrigin, response: LoadableSubject<Auth.OTP>) {
    requestOTP(mobileNumber: mobileNumber, countryCode: countryCode, mode: mode, userId: nil, inviteCode: nil, response: response)
  }
}

struct StubAuthInteractor: AuthInteractable {
  func verifyOTP(code: String, token: String, salt: String, response: LoadableSubject<Auth.Verification>) {
    print("WARNING: Using stub StubAuthInteractor")
  }
  
  func requestOTP(mobileNumber: String, countryCode: String, mode: AuthInteractor.OTPOrigin, userId: String?, inviteCode: String?, response: LoadableSubject<Auth.OTP>) {
    print("WARNING: Using stub StubAuthInteractor")
  }
  
  func verifyInvite(code: String, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubAuthInteractor")
  }
  
  func verifySignInWithApple(code: String, idToken: String, mode: AuthInteractor.OTPOrigin, inviteCode: String?, userEmail: String?, response: LoadableSubject<Auth.Verification>) {
    print("WARNING: Using stub StubAuthInteractor")
  }
}
