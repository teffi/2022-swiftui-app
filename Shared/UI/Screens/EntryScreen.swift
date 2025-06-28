//
//  EntryScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/22/22.
//

import SwiftUI

struct EntryScreen: View {
  @Environment(\.injected) var dependencies: DIContainer
  @State private var proceedToGetStarted = false
  @State private var proceedToLogin = false
  @State private var showPaginationLabel = true
  @Binding var destinationRoute: AppState.ViewRouting.EntryRoute?

  var body: some View {
    ZStack {
      VStack {
        carousel
        swipeText
          .offset(y: showPaginationLabel ? -80 : 0)
          .padding(.horizontal, 34)
          .opacity(showPaginationLabel ? 1 : 0)
        
        VStack(spacing: 16) {
          createAccountButton
          signInButton
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
      }
      
      
      NavigationLink(tag: .login, selection: $destinationRoute) {
        LoginSignupScreen()
          .environment(\.loginSignupActivity, .login)
      } label: { EmptyView() }
      
      NavigationLink(tag: .signup, selection: $destinationRoute) {
        InviteCodeScreen()        
      } label: { EmptyView() }

      
      //  Hack for iOS 14.5
      //  Issue: SwiftUI NavigationLink pops out by itself
      //  Cause: Happening in places where there's multiple navigation link
      //  https://developer.apple.com/forums/thread/677333
      NavigationLink(destination: EmptyView()) {
        EmptyView()
      }
    }
    .background(backgroundImage)
    .navigationBarHidden(true)
    .navigationBarTitleDisplayMode(.inline)
  }
}
//  MARK: - Views
extension EntryScreen {
  
  private var swipeText: some View {
    Text("Swipe to view more →")
      .fontRegular(size: 16)
      .fgAssetColor(.white)
  }
  
  private var backgroundImage: some View {
    Image.asset(.onboarding_background_gradient)
      .scaleFill()
      .ignoresSafeArea()
  }
  
  private var carousel: some View {
    TabView {
      Image.asset(.onboarding_p1)
        .scaleFill()
        .offset(y: -20)
        .transition(.opacity)
      Image.asset(.onboarding_p2)
        .scaleFill()
        .offset(y: -20)
        .onAppear {
          showPaginationLabel = false
        }
        .onDisappear {
          showPaginationLabel = true
        }
    }
    .tabViewStyle(.page(indexDisplayMode: .always))
  }
  
  private var createAccountButton: some View {
    Button {
      dependencies.appState.routing.entry = .signup
    } label: {
      Text("Create account")
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .fontBold(size: 16)
        .fgAssetColor(.black)
        .contentShape(Rectangle())
    }
    .bgAssetColor(.white)
    .cornerRadius(8)
    .buttonStyle(.plain)
  }
  
  private var signInButton: some View {
    Button {
      dependencies.appState.routing.entry = .login
    } label: {
      Text("Sign in")
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .fontBold(size: 16)
        .fgAssetColor(.white)
        .contentShape(Rectangle())
    }
    .addBorder(color: .white, cornerRadius: 8)
    .buttonStyle(.plain)
  }
}

struct EntryScreen_Previews: PreviewProvider {
  static var previews: some View {
    EntryScreen(destinationRoute: .constant(.login))
  }
}

