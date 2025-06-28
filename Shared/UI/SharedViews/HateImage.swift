//
//  HateImage.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

struct HateImage: View {
    var body: some View {
      Image(Sentiment.hate.iconName)
        .icon()
    }
}

struct HateImage_Previews: PreviewProvider {
    static var previews: some View {
        HateImage()
    }
}
