//
//  ForEachWithIndex.swift
//  Dash
//
//  Created by Steffi Tan on 2/8/22.
//

import SwiftUI

/// ForEach viewbuilder with returned index.
/// - Important:`data` must conform to identifiable
/// - Uses Array and zip to get indices of data
/// - Reference: https://onmyway133.com/posts/how-to-use-foreach-with-indices-in-swiftui/
struct ForEachWithIndex<
  Data: RandomAccessCollection,
  Content: View
>: View where Data.Element: Identifiable, Data.Element: Hashable {
  let data: Data
  @ViewBuilder let content: (Data.Index, Data.Element) -> Content
  
  var body: some View {
    ForEach(Array(zip(data.indices, data)), id: \.1) { index, element in
      content(index, element)
    }
  }
}

