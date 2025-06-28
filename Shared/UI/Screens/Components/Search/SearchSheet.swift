//
//  SearchSheet.swift
//  Dash
//
//  Created by Steffi Tan on 2/9/22.
//

import SwiftUI

struct SearchSheet: View {
  @EnvironmentObject var environment: SearchEnvData
  var title: String =  "Search a product"
  
  var displayTitle: String {
    if let question = environment.tab?.searchQuestion {
      return question.body
    }
    return title
  }
  
  var body: some View {
    VStack {
      Text(displayTitle)
        .fontHeavy(size: 18)
        .fgAssetColor(.black)
        .lineSpacing(3)
        .lineLimit(nil)
        .multilineTextAlignment(.center)
      //  Only 13 on bottom due to Searchscreen's search bar top padding of 7.
        .padding(.init(top: 20, leading: 20, bottom: 13, trailing: 20))
      SearchScreen()
        .environment(\.searchPresentation, .sheet)
    }
  }
}

struct SearchSheet_Previews: PreviewProvider {
  static var previews: some View {
    SearchSheet()
  }
}
