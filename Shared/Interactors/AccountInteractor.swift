//
//  AccountInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 3/28/22.
//

import Foundation

protocol AccountInteractable {
  func updateMobile(userId: String,
                    mobileNumber: String,
                    countryCode: String,
                    otpCode: String,
                    token: String,
                    salt: String,
                    response: LoadableSubject<Account.MobileUpdateResponse>)
}

struct AccountInteractor: AccountInteractable {
  let api: AccountAPI
  func updateMobile(userId: String,
                    mobileNumber: String,
                    countryCode: String,
                    otpCode: String,
                    token: String,
                    salt: String,
                    response: LoadableSubject<Account.MobileUpdateResponse>) {
    
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.updateMobile(userId: userId,
                     body: ["mobile_number": mobileNumber,
                            "mobile_country_code": countryCode,
                            "otp": otpCode,
                            "user_token": token,
                            "auth_salt": salt])
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
}

struct StubAccountInteractor: AccountInteractable {
  func updateMobile(userId: String, mobileNumber: String, countryCode: String, otpCode: String, token: String, salt: String, response: LoadableSubject<Account.MobileUpdateResponse>) {
    print("WARNING: Using stub StubAccountInteractor")
  }
}

//mobile_number
//mobile_country_code
//otp
//auth_salt
//user_token
