//
//  RichText.swift
//  Dash
//
//  Created by Steffi Tan on 2/17/22.
//

import SwiftUI

/// Render double asterisk (* *)  as bold.
/// - Splits text, apply styling and re-assemble them
/// Ref: https://www.avanderlee.com/swiftui/text-weight-combinations/
//  TODO: Add support to different types of bold weights via markup. ("***" - semi bold, etc...)
struct RichText: View {
  /// Font weight applied to bold text.
  var boldWeight: Font.Weight = .heavy
  
  struct Element: Identifiable {
    let id = UUID()
    let content: String
    let isBold: Bool
    let shouldAddSpaceAfter: Bool
    
    init(content: String, isBold: Bool, shouldAddSpaceAfter: Bool = true) {
      var content = content.trimmingCharacters(in: .whitespacesAndNewlines)
      
      if isBold {
        content = content.replacingOccurrences(of: "**", with: "")
      }
      
      self.content = content
      self.isBold = isBold
      self.shouldAddSpaceAfter = shouldAddSpaceAfter
    }
  }
  
  let elements: [Element]
  
  init(_ content: String, boldWeight: Font.Weight = .heavy) {
    elements = content.parseRichTextElements()
    self.boldWeight = boldWeight
  }
  
  var body: some View {
    guard !elements.isEmpty else { return Text("")}
    var content = text(for: elements.first!)
    elements.dropFirst().forEach { (element) in
      content = content + self.text(for: element)
    }
    return content
  }
  
  private func text(for element: Element) -> Text {
    let postfix = shouldAddSpace(for: element) ? " " : ""
    if element.isBold {
      return Text(element.content + postfix)
        .fontWeight(boldWeight)
    } else {
      return Text(element.content + postfix)
    }
  }
  
  private func shouldAddSpace(for element: Element) -> Bool {
    return (element.id != elements.last?.id) && element.shouldAddSpaceAfter
  }
}


extension String {
  /// Parses the input text and returns a collection of rich text elements.
  /// Currently supports asterisks only. E.g. "Save *everything* that *inspires* your ideas".
  ///
  /// - Returns: A collection of rich text elements.
  func parseRichTextElements() -> [RichText.Element] {
    let regex = try! NSRegularExpression(pattern: "\\*{2}(.*?)\\*{2}")
    let range = NSRange(location: 0, length: count)
    
    /// Find all the ranges that match the regex *CONTENT*.
    let matches: [NSTextCheckingResult] = regex.matches(in: self, options: [], range: range)
    let matchingRanges = matches.compactMap { Range<Int>($0.range) }
    
    var elements: [RichText.Element] = []
    
    // Add the first range which might be the complete content if no match was found.
    // This is the range up until the lowerbound of the first match.
    let firstRange = 0..<(matchingRanges.count == 0 ? count : matchingRanges[0].lowerBound)
    
    self[firstRange].components(separatedBy: " ").forEach { (word) in
      guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
      elements.append(RichText.Element(content: String(word), isBold: false))
    }
    
    // Create elements for the remaining words and ranges.
    for (index, matchingRange) in matchingRanges.enumerated() {
      let isLast = matchingRange == matchingRanges.last
      
      // Add an element for the matching range which should be bold.
      let matchContent = self[matchingRange]
      
      //  Evaluate based on next character if the element should have space. Ex: **D**,      
      let nextCharRange = matchingRange.upperBound..<matchingRange.upperBound + 1
      //  Extract next character from the string if there's still a character after the current match.
      //  IMPT: the upper bound and string count check makes sure that we dont try and subscript beyond the string range.
      let nextChar = nextCharRange.upperBound <= (self.count) ? self[nextCharRange] :  ""
      let willAddSpaceAfter = ((nextChar == "") || (nextChar == " "))
      
      elements.append(RichText.Element(content: matchContent,
                                       isBold: true,
                                       shouldAddSpaceAfter: willAddSpaceAfter))
      
      // Add an element for the text in-between the current match and the next match.
      let endLocation = isLast ? count : matchingRanges[index + 1].lowerBound
      let range = matchingRange.upperBound..<endLocation
      self[range].components(separatedBy: " ").forEach { (word) in
        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        elements.append(RichText.Element(content: String(word), isBold: false))
      }
    }
    return elements
  }
  
  /// - Returns: A string subscript based on the given range.
  subscript(range: Range<Int>) -> String {
    let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
    let endIndex = index(self.startIndex, offsetBy: range.upperBound)
    return String(self[startIndex..<endIndex])
  }
}
