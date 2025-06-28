//
//  ReportScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/30/22.
//

import SwiftUI

struct ReportScreen: View {
  @Environment(\.reportType) var reportType
  @Environment(\.injected) var dependencies
  @Environment(\.presentationMode) var presentation
  @State private var text = ""
  @State private var report: Loadable<Response> = .idle
  @State private var isPresentedSuccessAlert = false
  let id: String
  
  var body: some View {
    ZStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 20) {
        Text("Tell us more information about your issue.")
          .fontRegular(size: 16)
          .fgAssetColor(.black, opacity: 0.4)
        
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fgAssetColor(.gray_1)
          TextView($text)
            .enableScrolling(true)
            .fontRegular(size: 20)
            .fgAssetColor(.black)
            .padding(10)
        }.frame(maxWidth: .infinity, maxHeight: 200)
        
        Button("Submit") {
          submit()
        }
        .appButtonStyle(.primaryFullWidth)
        Spacer()
      }
      .padding(.all, 20)
      
      .alert(isPresented: $isPresentedSuccessAlert) {
        Alert(title: Text("Submission successful"),
              message: nil,
              dismissButton: .default(Text("OK"), action: {
          presentation.wrappedValue.dismiss()
        }))
      }
      
      buildReport
    }
    .navigationTitle(reportType.title)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarHidden(false)
  }
}

// MARK: - Views
extension ReportScreen {
  @ViewBuilder private var buildReport: some View {
    switch report {
    case .idle:
      Color.clear
    case .loaded:
      Color.clear.onAppear {
        isPresentedSuccessAlert = true
      }
    case .failed(let response):
      Color.clear.onAppear {
        var alertTitle = "Something went wrong"
        var alertMessage = response.localizedDescription
        if let err = response.asAPIError {
          alertTitle = err.alert.title
          alertMessage = err.alert.message
        }
        dependencies.appState.showAlert(title: alertTitle,
                                        message: alertMessage)
      }
    case .isLoading:
      Color.black.opacity(0.05).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
}

// MARK: - API
extension ReportScreen {
  func submit() {
    switch reportType {
    case .review:
      dependencies.interactors.reportInteractor
        .reportReview(id: id, body: text, response: $report)
    case .comment:
      dependencies.interactors.reportInteractor
        .reportComment(id: id, body: text, response: $report)
    case .user:
      dependencies.interactors.reportInteractor
        .reportUser(id: id, body: text, response: $report)
    }
  }
}

//  MARK: - Preview
struct ReportScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ReportScreen(id: "sampleid")
    }
  }
}

//  MARK: - Environment
struct ReportTypeKey: EnvironmentKey {
  static var defaultValue: ReportType = .user
  enum ReportType {
    case user, review, comment
    var title: String {
      switch self {
      case .comment:
        return "Report a comment"
      case .review:
        return "Report a review"
      case .user:
        return "Report an issue"
      }
    }
  }
}
//  MARK: Values
extension EnvironmentValues {
  var reportType: ReportTypeKey.ReportType {
    get { self[ReportTypeKey.self] }
    set { self[ReportTypeKey.self] = newValue }
  }
}

