//
//  AppDelegate.swift
//  Dash
//
//  Created by Steffi Tan on 2/18/22.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    configureNavigationBarAppearance()
    configureTabBarApperance()
    return true
  }
  
  private func configureNavigationBarAppearance() {
    //  Make the navigation bar solid white.
    let navBarAppearance = UINavigationBar.appearance()
    
    //  OS agnostic setup
    navBarAppearance.isTranslucent = false
    navBarAppearance.barTintColor = .white
    
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    appearance.shadowImage = nil
    appearance.shadowColor = .clear
//    appearance.titleTextAttributes = [
//      NSAttributedString.Key.font: UIFont.BananaGrotesk(weight: .semibold, size: 16.0),
//      NSAttributedString.Key.foregroundColor: UIColor.Function.black
//    ]
    navBarAppearance.barTintColor = .white
    
    // Back button
    let barImage = UIImage(named: AssetImage.ic_nav_back.name)
    appearance.setBackIndicatorImage(barImage, transitionMaskImage: barImage)
    
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
  }
  
  private func configureTabBarApperance() {    
    //  Make tabbar look invisible
    let tabBarAppeareance = UITabBarAppearance()
    tabBarAppeareance.shadowColor = .clear
    tabBarAppeareance.backgroundColor = .clear
    tabBarAppeareance.backgroundImage = UIImage()
    UITabBar.appearance().standardAppearance = tabBarAppeareance
    if #available(iOS 15.0, *) {
      UITabBar.appearance().scrollEdgeAppearance = tabBarAppeareance
    }
  }
}
