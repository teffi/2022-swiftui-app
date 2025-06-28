//
//  Resources.swift
//  Dash
//
//  Created by Steffi Tan on 3/22/22.
//

import SwiftUI

//  MARK: - Asset Image
enum AssetImage: String {
  case onboarding_background_gradient
  case onboarding_p1
  case onboarding_p2
  
  case ic_plus_gradient
  case ic_love
  case ic_hate
  case ic_camera_fill
  case ic_bubble_search
  case ic_bubble_smile
  case ic_send
  case ic_comment_bubble
  case ic_notifications
  case ic_settings
  case ic_person_add
  case ic_nav_back
  
  //  Tab icons
  case ic_account_circle_outline
  case ic_account_circle_fill
  case ic_home_outline
  case ic_home_fill
  case ic_thumb_up_fill
  case ic_thumb_up_outline
  
  var name: String {
    return rawValue
  }
}

extension Image {
  static func asset(_ asset: AssetImage) -> Image {
    return Image(asset.name)
  }
}

//  MARK: - Local JSON
struct Resources {
  static func readJSONFile(with fileName: String) -> Data? {
    do {
      if let bundlePath = Bundle.main.path(forResource: fileName, ofType: "json"),
         let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
        return jsonData
      }
    } catch {
      print(error)
    }
    return nil
  }
}
