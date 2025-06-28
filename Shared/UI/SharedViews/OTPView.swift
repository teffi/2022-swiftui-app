//
//  OTPView.swift
//  Dash
//
//  Created by Steffi Tan on 3/28/22.
//

import SwiftUI
import Combine

//  MARK: - OTP
struct OTP {
  struct Request {
    let mobileNumber: String
    let countryCode: String
    let userId: String?
    let inviteCode: String?
    let mode: AuthInteractor.OTPOrigin
  }
}
//  MARK: - OTP Protocol
protocol OTPCompatible {
  var token: String { get set }
  var salt: String { get set }
  var requestCodeData: OTP.Request? { get set }
}

struct OTPView: View {
  @Environment(\.injected) private var dependencies  
  @StateObject private var model = OTPModel()
  @State private var otpCodeRequest: Loadable<Auth.OTP> = .idle
  @State private var isPresentingAlert = false
  @State private var alert: (title: String, message: String) = (title: "", message: "")
  @Binding var code: String
  @Binding var isValid: Bool
  var requestCodeData: OTP.Request?
  
  var body: some View {
    ZStack(alignment: .bottom) {
      content
      footer
      buildOTPCodeRequest
        .alert(isPresented: $isPresentingAlert) {
          Alert(title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .cancel(Text("OK")))
        }
    }
    //  Subscribe to otp validity
    .onChange(of: model.isValid) { newValue in
      isValid = newValue
      code = model.fullCode
    }
  }
}

struct OTPView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      OTPView(code: .constant(""), isValid: .constant(false))
    }
  }
}


// MARK: - Views
extension OTPView {
  private var content: some View {
    VStack(alignment: .center, spacing: 30) {
      Text("You’ll receive a 6-digit code to verify\nyour number")
        .fontRegular(size: 16)
        .multilineTextAlignment(.center)
      HStack(spacing: 8) {
        otpTextDisplay(text: model.codes[safe: 0] ?? "")
        otpTextDisplay(text: model.codes[safe: 1] ?? "")
        otpTextDisplay(text: model.codes[safe: 2] ?? "")
        otpTextDisplay(text: model.codes[safe: 3] ?? "")
        otpTextDisplay(text: model.codes[safe: 4] ?? "")
        otpTextDisplay(text: model.codes[safe: 5] ?? "")
      }
      .overlay(alignment: .bottom, content: {
        TextField("", text: $model.otpCode)
          .frame(maxHeight: .infinity)
          .textContentType(.oneTimeCode)
          .accentColor(Color.clear)
          .foregroundColor(Color.clear)
          .background(Color.clear)
          .keyboardType(.numberPad)
        //  Limit text to 5 characters. This is called multiple times
          .onReceive(Just(model.otpCode)) { inputValue in
            if inputValue.count > model.limit {
              model.otpCode = inputValue[0..<model.limit]
            }
          }
      })
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .introspectTextField { field in
      //  Note: This causes the bottom whitespace on preview which is where the keyboard is
      // TODO: This triggers previous screen to rerender the navigation link
      field.becomeFirstResponder()
    }
  }
  
  private var footer: some View {
    VStack(spacing: 0) {
      Text("Didn't receive code?")
        .fontRegular(size: 12)
      Button("Request again") {
        if let data = requestCodeData {
          requestOTP(with: data)
        }
      }
      .buttonStyle(.plain)
      .fontHeavy(size: 16)
      .fgAssetColor(.purple)
      .padding(10)
    }
    .padding(.bottom, 20)
  }
  
  private func otpTextDisplay(text: String) -> some View {
    Text(text)
      .frame(width: 44, height: 44)
      .fgAssetColor(.black)
      .fontRegular(size: 16)
      .bgAssetColor(.gray_1)
      .multilineTextAlignment(.center)
      .lineLimit(1)
      .cornerRadius(8)
      .fixedSize()
  }
  
  @ViewBuilder private var buildOTPCodeRequest: some View {
    switch otpCodeRequest {
    case .loaded(_):
      Color.clear.onAppear {
        alert = (title: "Sent", message: "You'll receive your new 6 digit code shortly.")
        isPresentingAlert = true
      }
    case .failed(let response):
      Color.clear.onAppear {
        showAlert(error: response)
      }
    default:
      Color.clear
    }
  }
}

//  MARK: - Alert
extension OTPView {
  func showAlert(error: Error) {
    var alertTitle = "Something went wrong"
    var alertMessage = error.localizedDescription
    if let err = error.asAPIError {
      alertTitle = err.alert.title
      alertMessage = err.alert.message
    }
    alert = (title: alertTitle, message: alertMessage)
    isPresentingAlert = true
  }
}
//  MARK: - API
extension OTPView {
  func requestOTP(with data: OTP.Request) {
    dependencies.interactors
      .authInteractor
      .requestOTP(mobileNumber: data.mobileNumber,
                  countryCode: data.countryCode,
                  mode: data.mode,
                  userId: data.userId,
                  inviteCode: data.inviteCode,
                  response: $otpCodeRequest)
  }
}

// MARK: - Model
class OTPModel: ObservableObject {
  @Published var otpCode: String = ""
  @Published var codes: [String]
  @Published var isValid: Bool = false
  private(set) var limit = 6
  private var cancelBag = CancelBag()
  private var validPublisher: AnyPublisher<Bool, Never> {
    $codes
      .map {
        $0.allSatisfy { $0.count == 1 }
      }
      .eraseToAnyPublisher()
  }
  
  /**
   - Returns: A String with merged codes.
   */
  var fullCode: String {
    get {
      return self.codes.joined()
    }
  }
  
  init() {
    codes = Array(repeating: "", count: limit)
    validPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.isValid, on: self)
      .store(in: cancelBag)
    
    $otpCode
      .removeDuplicates()
    //  For safeguarding. Limit the number of characters received in .sink.
      .map({ text -> String in
        if text.count <= self.limit {
          return text
        } else {
          return text[0..<self.limit]
        }
      })
      .sink { value in
        //  Store values in their corresponding code index.
        let valueArray = Array(value)
        for i in 0..<self.codes.count {
          if let char = valueArray[safe: i] {
            self.codes[i] = String(char)
          } else {
            //  Executes if text received count is less than our limit.
            self.codes[i] = ""
          }
        }
      }
      .store(in: cancelBag)
  }
}
