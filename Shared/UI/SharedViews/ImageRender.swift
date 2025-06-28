//
//  ImageRender.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import SwiftUI
import URLImage

// TODO: Add retry on failed request
/// View container for URLImage that handles the ff
/// - Convert url path to `URL`
/// - Set standard  placeholder layout
/// - Set standard  failed state layout
struct ImageRender<Content: View> : View {
  private let url: String
  private let remoteURL: URL?
  private var content: (Image) -> Content
  private(set) var placeholderRadius: CGFloat = 0
  
  
  init(urlPath: String,
       placeholderRadius: CGFloat = 0,
       content: @escaping (_ image: Image) -> Content) {
    url = urlPath
    remoteURL = URL(string: urlPath)
    self.content = content
    self.placeholderRadius = placeholderRadius
  }

  var body: some View {
    if let remoteURL = remoteURL {
      URLImage(remoteURL,
               inProgress: { progress in
        ThumbnailPlaceholder()
      }, failure: { error, retry in
        
        ZStack {
          ThumbnailPlaceholder()
          Image(systemName: "xmark.octagon")
            .foregroundColor(Color.gray)
        }
        .contentShape(Rectangle())
//        Uncomment once retry is supported
//        .onTapGesture {
//          print("rety loading image")
//        }
      }, content: content)
    } else {
      // Invalid remote url
      ThumbnailPlaceholder()
    }
  }
}
