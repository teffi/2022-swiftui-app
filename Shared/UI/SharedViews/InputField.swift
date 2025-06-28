//
//  InputField.swift
//  Dash
//
//  Created by Steffi Tan on 2/21/22.
//

import SwiftUI

struct InputField: View {
  @Binding var text: String
  @State var showFieldLabel = false
  @Binding var isValidInput: Bool
  @Binding var isReadOnly: Bool?
  
  let title: String
  let note: String?
  let isRequired: Bool
  
  init(text: Binding<String>, title: String, note: String? = nil, isReadOnly: Binding<Bool?>? = nil, isRequired: Bool = true, isValid: Binding<Bool>) {
    self.title = title
    self.note = note
    self.isRequired = isRequired
    _text = text
    _isReadOnly = isReadOnly ?? .constant(nil)
    _isValidInput = isValid
  }
  
  private var fieldPadding: EdgeInsets {
    return showFieldLabel ? .init(top: 0, leading: 0, bottom: 5, trailing: 0) : .init(top: 14, leading: 0, bottom: 14, trailing: 0)
  }
  
  private var field: some View {
    TextField(title + (isRequired ? "" : " (Optional)"), text: $text)
      .fontRegular(size: 16)
      .fgAssetColor(.black)
      .padding(fieldPadding)
      .background(Color(.white))
      .cornerRadius(8)
      .onChange(of: text, perform: fieldTextChanged(text:))
  }
  
  private var label: some View {
    Text(title)
      .fontBold(size: 11.5)
      .padding(.top, 4)
  }
  
  @ViewBuilder private var noteLabel: some View {
    let noteText = note ?? ""
    if !noteText.isEmpty {
      Text(noteText)
        .fontRegular(size: 14)
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 4) {
        if showFieldLabel {
          label
        }
        field.disabled(isReadOnly ?? false)
      }
      
      .overlay(alignment: .trailing, content: {
        if isValidInput {
          Image(systemName: "checkmark.circle.fill")
            .fgAssetColor(.green)
            .frame(width: 16, height: 16)
        }
      })
      .padding(.horizontal, 16)
      .background(Color.white)
      .cornerRadius(8)
      
     noteLabel
    }
  }
}

// MARK: - Functions
extension InputField {
  
  private func fieldTextChanged(text: String) {
    //   TODO: Update validity to be based from textfield rule
    if !text.isEmpty {
      isValidInput = true
      showFieldLabel = true
    } else {
      isValidInput = false
      showFieldLabel = false
    }
  }
}

struct InputField_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      InputField(text: .constant(""), title: "Name", note: "e.g. \"Camper and outdoor person during weekends\"", isValid: .constant(true))
      Spacer()
    }
    .background(Color.gray)
  }
}

