//
//  DatePickerCalendar.swift
//  Dash
//
//  Created by Steffi Tan on 2/21/22.
//

import SwiftUI

struct DatePickerCalendar: View {
  
  @Binding var showDatePicker: Bool
  @Binding var savedDate: Date?
  @State var selectedDate: Date = Date()
  
  private var cancelButton: some View {
    Button(action: {
      showDatePicker = false
    }, label: {
      Text("Cancel")
    })
  }
  
  private var saveButton: some View {
    Button(action: {
      savedDate = selectedDate
      showDatePicker = false
    }, label: {
      Text("Save".uppercased())
        .bold()
    })
  }
  
  private var maxBdate: Date {
    return Calendar.current.date(byAdding: .year, value: -16, to: Date()) ?? Date()
  }
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.5).ignoresSafeArea()
      VStack {
        DatePicker("", selection: $selectedDate, in: ...maxBdate, displayedComponents: [.date])
          .datePickerStyle(GraphicalDatePickerStyle())
        Divider()
          .padding(.bottom, 10)
        HStack {
          cancelButton
          Spacer()
          saveButton
        }
        .padding(.horizontal)
      }
      .padding()
      .background(
        Color.white.cornerRadius(20)
      )
      .padding(20)
      .frame(maxHeight: .infinity)
    }
  }
}

struct DatePickerCalendar_Previews: PreviewProvider {
  static var previews: some View {
    DatePickerCalendar(showDatePicker: .constant(true), savedDate: .constant(Date()))
  }
}
