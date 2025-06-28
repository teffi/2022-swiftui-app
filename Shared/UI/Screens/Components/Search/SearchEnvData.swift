//
//  SearchEnvData.swift
//  Dash
//
//  Created by Steffi Tan on 2/9/22.
//

import SwiftUI

class SearchEnvData: ObservableObject {
  /// When search is on sheet presentation, it needs to communicate to the TabController to invoke presentation of product screen.
  weak var tab: TabController?
}

extension SearchEnvData {
  struct Question {
    let id: String
    let body: String
  }
}
