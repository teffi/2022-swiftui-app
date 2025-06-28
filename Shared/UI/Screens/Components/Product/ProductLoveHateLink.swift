//
//  ProductLoveHateLink.swift
//  Dash
//
//  Created by Steffi Tan on 2/11/22.
//

import SwiftUI

struct ProductLoveHateLink: View {
  
  @Environment(\.injected) private var dependencyEnv: DIContainer
  @Environment(\.onboardingForm) private var isOnboarding
  @ObservedObject var form: ProductReviewForm
  @EnvironmentObject private var productEnv: ProductEnv
  
  let size: CGFloat
  let hasShadow: Bool
  let showTitle: Bool
  var spacing: CGFloat = 20
  
  var body: some View {
    HStack(spacing: spacing) {
      link(.love)
      link(.hate)
    }
  }
  
  @ViewBuilder func link(_ value: Sentiment) -> some View {
    NavigationLink {
      ProductReviewFormScreen(form: form)
        .inject(dependencyEnv)
        .environment(\.onboardingForm, isOnboarding)
        .environmentObject(productEnv)
        .onAppear {
          form.sentiment = value
        }
    } label: {
      switch value {
      case .love:
        VStack {
          LoveImage()
            .frame(width: size, height: size)
            .shadow(color: hasShadow ? Color.black.opacity(0.2) : .clear, radius: 8, x: 0, y: 6)
          if showTitle {
            Text("Rave")
              .fontRegular(size: 14)
              .fgAssetColor(.black)
          }
        }        
      case .hate:
        VStack {
          HateImage()
            .frame(width: size, height: size)
            .shadow(color: hasShadow ? Color.black.opacity(0.2) : .clear, radius: 8, x: 0, y: 6)
          if showTitle {
            Text("Roast")
              .fontRegular(size: 14)
              .fgAssetColor(.black)
          }
        }
      }
    }
  }
}

struct ProductLoveHateLink_Previews: PreviewProvider {
  static var previews: some View {
    ProductLoveHateLink(form: ProductReviewForm(), size: 61, hasShadow: true, showTitle: true)
  }
}

