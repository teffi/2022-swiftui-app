//
//  DashApp.swift
//  Shared
//
//  Created by Steffi Tan on 2/8/22.
//

import SwiftUI
import URLImage
import URLImageStore
import PopupView

@main
struct DashApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.openURL) var openURL
  
  @StateObject private var appState = AppState()
  @State private var isPresentingAppUpdate = false
  
  var body: some Scene {
    //  Configure to use memory storage to avoid reloading of image once loaded.
    //  Whenever the view is re-rendered, URLImage resets back to empty state.
    //  See URLImage package for more information.
    let urlImageService = URLImageService(fileStore: nil, inMemoryStore: URLImageInMemoryStore())
    
    WindowGroup {
      let environment = AppEnvironment.bootstrap(app: _appState)
      let routing = environment.container.appState.routing
      NavigationView {
        ZStack(alignment: .top) {
          switch routing.root {
          case .entry:
            let _ = print("nav link: rendering entry")
            EntryScreen(destinationRoute: $appState.routing.entry)
              .navigationBarHidden(true)
          case .tab:
            let _ = print("nav link: rendering tab")
            TabScreen(container: environment.container)
              .navigationBarHidden(true)
          }
        }
        //  App update popup
        .popup(isPresented: $isPresentingAppUpdate, type: .default, dragToDismiss: false, closeOnTap: false, closeOnTapOutside: false, backgroundColor: Color.black.opacity(0.7), view: {
          appUpdateView
        })
        
        .alert(isPresented: $appState.routing.showAlert) {
          Alert(title: Text(appState.routing.alertTitle ?? ""),
                message: Text(appState.routing.alertMessage ?? ""),
                dismissButton: .default(Text("OK"), action: {
            appState.clearAlert()
          }))
        }
        
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
      }
      .navigationViewStyle(.stack)
      .inject(environment.container)
      .environment(\.urlImageService, urlImageService)
      .onAppear {
        print("on appear root")
        appUpdateIfNeeded(container: environment.container)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
//          environment.container.appState.updateRoot(.tab)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//          environment.container.appState.routing.root = .tab
//        }
      }
    }
  }
}

//  MARK: - App update check
extension DashApp {
  func appUpdateIfNeeded(container: DIContainer) {
    container.interactors.feedInteractor.checkAppUpdate { shouldForceUpdate in
      print("should force app update \(shouldForceUpdate)")
      if shouldForceUpdate {
        isPresentingAppUpdate = true
      }
    }
  }
  
  @ViewBuilder private var appUpdateView: some View {
    VStack(alignment: .center, spacing: 12) {
      Text("New app version available")
        .fontBold(size: 20)
      Text("Please update your app for better app experience")
        .fontRegular(size: 16)
      
      Button("Update now") {
        UIApplication.shared.open(URL(string: "itms-apps://apple.com/app/id1208415803")!)
      }
      .padding(.top, 20)
      .appButtonStyle(.primary)
    }
    .multilineTextAlignment(.center)
    .fgAssetColor(.black)
    .padding(.all, 40)
    .bgAssetColor(.white)
    .cornerRadius(8)
  }
}
