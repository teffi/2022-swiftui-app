//
//  SearchEnvironment.swift
//  Dash
//
//  Created by Steffi Tan on 2/17/22.
//

import SwiftUI

//  MARK: - Keys
struct SearchPresentationKey: EnvironmentKey {
  static var defaultValue: Presentation = .sheet
  enum Presentation {
    //  Presented as sheet (aka present as modal)
    case sheet
    //  Presented from a Navigation Link (aka push)
    case fullScreen
    case onboarding
  }
}

//  MARK: Values
extension EnvironmentValues {  
  var searchPresentation: SearchPresentationKey.Presentation {
    get { self[SearchPresentationKey.self] }
    set { self[SearchPresentationKey.self] = newValue }
  }
}
