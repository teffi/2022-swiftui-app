//
//  OnboardingSearchScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/22/22.
//

import SwiftUI

struct OnboardingSearchScreen: View {
  //  TODO: Replace search env with custom without tab controller dependency
  @Environment(\.injected) private var dependencies: DIContainer
  @StateObject var searchEnv = SearchEnvData()
  @State var showSearchScreen = false
  
  //  Dependency
  let name: String
  
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        //  Add space to avoid headline view to be pushed to the top with the spacers after the searchbar.
        if !showSearchScreen {
          Spacer()
        }
        
        headline
        
        if !showSearchScreen {
          SearchBar(text: .constant(""), isEditable: false)
            .onTapGesture {
              showSearchScreen = true
            }
          Spacer()
          Spacer()
        }
      }
      .padding(20)
      
      if showSearchScreen {
        SearchScreen()
          .inject(dependencies)
          .environmentObject(searchEnv)
          .environment(\.searchPresentation, .onboarding)
      }
    }
    .navigationBarHidden(true)
  }
}

//  MARK: - View
extension OnboardingSearchScreen {
  @ViewBuilder private var headline: some View {
    Image.asset(.ic_bubble_search)
      .icon()
      .frame(width: 48, height: 48)
      .padding(.bottom, 20)
    Text("Hi \(name), share your first review so others might find it useful")
      .fontHeavy(size: 20)
      .lineLimit(nil)
  }
}

struct OnboardingSearchScreen_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingSearchScreen(name: "John")
  }
}

