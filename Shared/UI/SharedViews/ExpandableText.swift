//
//  ExpandableText.swift
//  Dash
//
//  Created by Steffi Tan on 3/25/22.
//

import SwiftUI

//  Inspired from https://github.com/FiveStarsBlog/CodeSamples/tree/main/Truncable-Text

/// Text with "read more" and "read less" function based on line limit.
/// How it works:
/// - Adding read more: If full text size exceeds the line limit size, it overlays a "read more" button that covers the last part.
/// - Adding read less: Appends "read less" text string to full text when view is expanded
/// - Important:
///   - This does not use substringing or trimming the text. It only relies on full text intrinsic and line limited size to handle what view to return
struct ExpandableText: View {
  let font: Font
  let lineLimit: Int
  let lineSpacing: CGFloat
  /// Should contain the similar color of this view's container. Defaults to white.
  /// Context: Becase we overlay "read more" with a solid background color, we have to match it with the container color
  let containerBgColor: AssetsColor
  @Binding var text: String
  /// If `true`, "read more" will get displayed if needed but it wont have any function to expand the text.
  @Binding var isReadOnly: Bool
  @State private var intrinsicSize: CGSize = .zero
  @State private var truncatedSize: CGSize = .zero
  @State private var isTruncated = false
  @State private var isExpanded = false
  
  init(text: Binding<String>,
       isReadOnly: Binding<Bool> = .constant(false),
       font: Font,
       lineLimit: Int,
       lineSpacing: CGFloat = 0,
       containerBgColor: AssetsColor = .white) {
    _text = text
    _isReadOnly = isReadOnly
    self.font = font
    self.lineLimit = lineLimit
    self.lineSpacing = lineSpacing
    self.containerBgColor = containerBgColor
  }
  private  var fullText: some View {
    return Text(text)
  }
  
  /// Returns a RichText layout with appended "read less" text and tap gesture for reverting to truncated version.
  private var expandedText: some View {
    RichText("\(text)**read less**", boldWeight: .bold)
      .font(font)
      .lineSpacing(lineSpacing)
      .fixedSize(horizontal: false, vertical: true)
      .onTapGesture {
        isExpanded.toggle()
      }
  }
  
  var body: some View {
    if isExpanded {
      expandedText
    } else {
      truncated
    }
  }
  
  @ViewBuilder private var truncated: some View {
    let readMoreTapGesture = TapGesture(count: 1).onEnded({ isExpanded = true })
    fullText
      .font(font)
      .lineLimit(lineLimit)
      .lineSpacing(lineSpacing)
    //  Behind the scene
    //  - get text size that fits the line limit. Used for comparison with intrinsic size
      .readSize { size in
        //  Called when size changes
        truncatedSize = size
        isTruncated = truncatedSize != intrinsicSize
      }
    
    //  Behind the scene, duplicate fullText with no limit to
    //  get text intrinsic size. Used for comparison with truncated size
      .background(
        fullText
          .font(font)
          .lineSpacing(lineSpacing)
          .fixedSize(horizontal: false, vertical: true)
          .hidden()
          .readSize { size in
            //  Called when size changes
            intrinsicSize = size
            isTruncated = truncatedSize != intrinsicSize
          }
      )
      .overlay(alignment: .bottomTrailing) {
        if isTruncated && !isExpanded {
          Text("...read more")
            .fontBold(size: 16)
            .fgAssetColor(.black)
            .bgAssetColor(containerBgColor)
          //  Add gesture if not readonly
            .gesture(isReadOnly ? nil : readMoreTapGesture)
        }
      }
  }
}
//  MARK: - PreferenceKey
public extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
      .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

//  MARK: - Preview
struct ExpandableText_Previews: PreviewProvider {
  static var previews: some View {
    ExpandableText(text: .constant("sample text"), font: .regular(size: 16), lineLimit: 3)
  }
}
