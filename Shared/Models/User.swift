//
//  User.swift
//  Dash
//
//  Created by Steffi Tan on 2/18/22.
//

import Foundation

struct ImageSet: Codable, Hashable {
  let originalUrl: String
  let smallUrl: String
  let mediumUrl: String
  let largeUrl: String

  private enum CodingKeys: String, CodingKey {
    case originalImageUrl, smallImageUrl, mediumImageUrl, largeImageUrl
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    originalUrl = try container.decodeIfPresent(String.self, forKey: .originalImageUrl) ?? ""
    smallUrl = try container.decodeIfPresent(String.self, forKey: .smallImageUrl) ?? ""
    mediumUrl = try container.decodeIfPresent(String.self, forKey: .mediumImageUrl) ?? ""
    largeUrl = try container.decodeIfPresent(String.self, forKey: .largeImageUrl) ?? ""
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(originalUrl, forKey: .originalImageUrl)
    try container.encode(smallUrl, forKey: .smallImageUrl)
    try container.encode(mediumUrl, forKey: .mediumImageUrl)
    try container.encode(largeUrl, forKey: .largeImageUrl)
  }
}

struct User: Decodable, Identifiable, Hashable {
  let id: String
  let displayName: String
  let fullName: String?
  let userName: String?
  let description: String?
  var profileImage: ImageSet?
//  @PicsumUnique var profileImageUrl: String?
  
  static var seed: User {
    return .init(id: "123", displayName: "John A", fullName: "John Appleseed", userName: "@johnapple", description: "Loves apple", profileImage: ImageSet.seed)
  }
  
  var initials: String {
    let names = displayName.components(separatedBy: " ")
    var extractedInitials = ""
    extractedInitials.append(String(names[safe: 0]?.prefix(1) ?? ""))
    extractedInitials.append(String(names[safe: 1]?.prefix(1) ?? ""))
    return extractedInitials
  }
}

//  MARK: - Sub models
extension User {
  struct Profile: Decodable, Identifiable {
    let id: String
    let displayName: String
    let fullName: String
    let firstName: String
    let lastName: String
    let userName: String?
    let description: String?
    let birthDate: String?
    let mobileNumber: String?
    let mobileCountryCode: String?
    let loveCount: Int
    let hateCount: Int
    let shareableProfileUrl: String?
    let profileImage: ImageSet?
    let inviteCode: String
    let inviteSpiel: String
    
    var atUsername: String {
      var formattedUsername = ""
      if let uname = userName, !uname.isEmpty {
        formattedUsername = "@" + uname
      }
      return formattedUsername
    }
    
    var initials: String {
      return String(firstName.prefix(1) + lastName.prefix(1))
    }
    
    static var seed: User.Profile {
      return .init(id: "1231",
                   displayName: "Jane Doe",
                   fullName: "Jane Doe",
                   firstName: "Jane",
                   lastName: "Doe",
                   userName: "@janedoe",
                   description: "Loves to cook and bake",
                   birthDate: nil,
                   mobileNumber: "9172823734",
                   mobileCountryCode: "+63",
                   loveCount: 10,
                   hateCount: 10,
                   shareableProfileUrl: nil,
                   profileImage: ImageSet.seed,
                   inviteCode: "Jane",
                   inviteSpiel: "Hi! I'm on Dash. Download the app at <app store link> and join using this invite code ANGELA")
    }
  }
}

//  MARK: - View specific model
extension User {
  var widgetDisplay: UserWidget.ViewModel {
    var formattedBio = ""
    if let bio = description, !bio.isEmpty {
      formattedBio = "\"\(bio)\""
    }
    
    var formattedUsername = ""
    if let uname = userName, !uname.isEmpty {
      formattedUsername = "@" + uname
    }
    
    return .init(name: displayName,
                 initials: initials,
                 username: formattedUsername,
                 bio: formattedBio,
                 imageUrl: profileImage?.smallUrl ?? "")
  }
}
