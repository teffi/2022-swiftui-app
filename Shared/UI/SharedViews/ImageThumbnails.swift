//
//  ImageThumbnails.swift
//  Dash
//
//  Created by Steffi Tan on 3/24/22.
//

import SwiftUI
//  TODO: Add support to `Image` and binding.
struct ImageThumbnails: View {
  var urls: [String]
  var columns = 4
  @State private var selectedImageUrl: String?
  var body: some View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: columns)
    LazyVGrid(columns: columns) {
      ForEach(urls) { url in
        ImageRender(urlPath: url) { image in
          image
            .thumbnail()
            .onTapGesture {
              selectedImageUrl = url
            }
        }
      }
    }
    //  IMPT: use variant of sheet constructed with item, do not use isPresented.
    //  Issue with using isPresented in for loop: https://stackoverflow.com/q/64066756/1045672
    //  Sol: https://stackoverflow.com/a/63217450/1045672
    .fullScreenCover(item: $selectedImageUrl) { item in
      let index = urls.firstIndex { $0 == item }
      PhotoViewer(imageUrls: urls, startIndex: index)
    }
  }
}

struct ImageThumbnails_Previews: PreviewProvider {
  static var previews: some View {
    ImageThumbnails(urls: ["https://picsum.photos/400/500"])
  }
}

