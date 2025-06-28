//
//  SettingsScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/28/22.
//

import SwiftUI

struct SettingsScreen: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject var profile: CreateProfileForm
  
  var body: some View {
    List {
      NavigationLink {
        ChangeMobileScreen()
          .environmentObject(profile)
      } label: {
        HStack {
          Text("Change mobile number")
            .fontRegular(size: 16)
          Spacer()
          Text(profile.mobileCountryCode + profile.mobileNumber)
            .fontRegular(size: 13)
        }
        .fgAssetColor(.black)
        .padding(.vertical, 20)
      }
      
      Button("Sign out") {
        signout()
      }
      .padding(.vertical, 20)
      .fgAssetColor(.warning)
    }
    
    .listStyle(.plain)
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.inline)
  }
}

//  MARK: Function
extension SettingsScreen {
  func signout() {
    dependencies.appState.removeUserSession()
    dependencies.appState.updateRoot(.entry)
  }
}

struct SettingsScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SettingsScreen().environmentObject(CreateProfileForm())
    }
    
  }
}
