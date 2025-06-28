//
//  Auth.swift
//  Dash
//
//  Created by Steffi Tan on 2/23/22.
//

import Foundation

struct Auth {
  struct OTP: Decodable {
    let userToken: String
    let authSalt: String
  }
  
  struct Verification: Decodable {
    let appSessionToken: String
    let user: User
    let newUser: Bool
  }
  
  struct AppleCredential: Codable {
    var idToken: String
    var userId: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var authCode: String
  }
}
