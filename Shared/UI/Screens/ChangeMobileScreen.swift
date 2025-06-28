//
//  ChangeMobileScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/28/22.
//

import SwiftUI

struct ChangeMobileScreen: View {
  @Environment(\.injected) var dependencies: DIContainer
  @EnvironmentObject var profile: CreateProfileForm
  
  @State private var otp: Loadable<Auth.OTP> = .idle
  @State private var requestCodeData: OTP.Request?
  @State private var showCountryList = false
  @State private var proceedToOTPScreen = false
  
  @State var mobileNumber = ""
  @State var country = CountryCodeList.deviceLocale
  var body: some View {
    VStack {
      HStack(spacing: 16) {
        countryCodeView
          .overlay(Divider().padding(.vertical, 6), alignment: .trailing)
        TextField("New mobile number", text: $mobileNumber)
          .fontRegular(size: 16)
          .fgAssetColor(.black)
          .keyboardType(.numberPad)
      }
      .bgAssetColor(.gray_1)
      .cornerRadius(8)
      .padding(.vertical, 30)
     
      Button("Change") {
        KeyboardResponder.dismiss()
        requestOTP()
        proceedToOTPScreen = true
      }
      .appButtonStyle(.primaryFullWidth)
      
      Spacer()
      
      NavigationLink(isActive: $proceedToOTPScreen) {
        if let otpData = otp.value {
          ChangeMobileOTPScreen(token: otpData.userToken,
                                salt: otpData.authSalt,
                                requestCodeData: requestCodeData)
            .environmentObject(profile)
        }
      } label: {
        EmptyView()
      }
    }
    .padding(.horizontal, 20)
    .navigationTitle("Change mobile")
    .navigationBarTitleDisplayMode(.inline)
  }
}

//  MARK: - View
extension ChangeMobileScreen {
  private var countryCodeView: some View {
    Button {
      showCountryList.toggle()
    } label: {
      Text(country.phoneCodeWithSymbol)
        .fontRegular(size: 16)
        .fgAssetColor(.black)
        .padding(.trailing, 20)
        .overlay(alignment: .bottomTrailing) {
          Image(systemName: "chevron.down")
            .imageScale(.small)
            .frame(maxHeight: .infinity)
            .fgAssetColor(.black)
            .offset(x: 5)
        }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .sheet(isPresented: $showCountryList) {
      CountryCodeList(selectedCountry: $country)
    }
  }
  
  @ViewBuilder func buildOTPRequest() -> some View {
    switch otp {
    case .idle:
      Color.clear
    case .loaded:
      Color.clear.onAppear {
        proceedToOTPScreen = true
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
    case .isLoading(_, _):
      Color.black.opacity(0.05).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
  
}

//  MARK: - API
extension ChangeMobileScreen {
  func requestOTP() {
    requestCodeData = .init(mobileNumber: mobileNumber,
                            countryCode: country.phoneCodeWithSymbol,
                            userId: profile.userId,
                            inviteCode: nil,
                            mode: .changeMobile)
    dependencies.interactors
      .authInteractor
      .requestOTP(mobileNumber: mobileNumber,
                  countryCode: country.phoneCodeWithSymbol,
                  mode: .changeMobile,
                  userId: profile.userId,
                  inviteCode: nil,
                  response: $otp)
  }
}

struct ChangeMobileScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ChangeMobileScreen()
        .environmentObject(CreateProfileForm(profile: User.Profile.seed))
    }
    
  }
}
