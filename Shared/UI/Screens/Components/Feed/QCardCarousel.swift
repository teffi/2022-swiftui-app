//
//  QCardCarousel.swift
//  Dash
//
//  Created by Steffi Tan on 2/13/22.
//

import SwiftUI

struct QCardCarousel: View {
  @EnvironmentObject var tabEnvironment: TabController
  
  let questions: [FeedQuestion]
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(alignment: .top, spacing: 8) {
        ForEach(questions) { question in
          Button {
            //  Route to search
            tabEnvironment.goToSearch(question: .init(id: question.id, body: question.body))
          } label: {
            QCard(title: question.body)
          }
          .appButtonStyle(.flatLink)
        }
      }
      .padding(.horizontal, 20)
    }
  }
}

struct QCardCarousel_Previews: PreviewProvider {
  static var previews: some View {
    QCardCarousel(questions: [FeedQuestion.seed])
  }
}

