//
//  CreateProfileScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/21/22.
//

import SwiftUI
import Cloudinary
import URLImage

struct CreateProfileScreen: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @Environment(\.editMode) private var editMode
  @EnvironmentObject var form: CreateProfileForm
  
  //  Dates
  @State private var showDatePicker = false
  @State private var selectedDate = Date()
  @State private var savedDate: Date? = nil
  
  @State private var profile: Loadable<Profile> = .idle
  @State private var proceedToOnboarding = false
  
  @State private var isPresentingAlert = false
  @State private var alert: (title: String, message: String) = (title: "", message: "")
  
  @Binding var hasBeenEdited: Bool?
  
  var isEditing: Bool {
    return editMode?.wrappedValue.isEditing ?? false
  }
  
  init(hasBeenEdited: Binding<Bool?> = .constant(false)) {
    _hasBeenEdited = hasBeenEdited
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      content
      birthdatePicker
      
      NavigationLink(isActive: $proceedToOnboarding) {
        OnboardingSearchScreen(name: form.firstName)
          .inject(dependencies)
      } label: {
        EmptyView()
      }

      buildPost()
    }
    .background(Color.assetColor(.gray_1).ignoresSafeArea())
    .navigationTitle(isEditing ? "Edit profile" :  "Create profile")
    .navigationBarHidden(false)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { editingToolbar }
  }
}

//  MARK: - Views
extension CreateProfileScreen {
  
  @ViewBuilder private var content: some View {
    ScrollView {
      VStack(spacing: 24) {
        //  Show profile image only when not editing
        if !isEditing {
          ProfileImage(imageUrl: $form.profileImageUrl, size: .init(width: 118, height: 118), actionIconConfiguration: .large)
        }
        Spacer(minLength: 10)
        inputFields
        Spacer()
        if !isEditing {
          finishButton
        }
      }
      .padding(28)
      .alert(isPresented: $isPresentingAlert) {
        Alert(title: Text(alert.title),
              message: Text(alert.message),
              dismissButton: .cancel(Text("OK")))
      }
    }
    .padding(.top, 20)
  }
  
  @ViewBuilder private var finishButton: some View {
    HStack {
      Spacer()
      Button("Finish") {
        KeyboardResponder.dismiss()
        submit()
      }
      .appButtonStyle(form.isValidAllRequiredValues ? .primary : .grayscalePrimary)
      .disabled(!form.isValidAllRequiredValues)
    }
  }
  
  @ToolbarContentBuilder
  var editingToolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      if isEditing {
        Button("Save") {
          KeyboardResponder.dismiss()
          submit()
        }
        .fontHeavy(size: 16)
        .fgAssetColor(.purple)
      }
    }
  }
  
  @ViewBuilder private var inputFields: some View {
    HStack(alignment: .top, spacing: 6) {
      InputField(text: $form.firstName, title: "First name", isValid: requiredValuesbinding(for: .firstName))
      InputField(text: $form.lastName, title: "Last name", isValid: requiredValuesbinding(for: .lastName))
    }
    
    InputField(text: $form.birthdate, title: "Birthdate", isReadOnly: .constant(true), isRequired: false, isValid: nonRequiredValuesBinding(for: .birthdate))
      .onTapGesture {
        showDatePicker.toggle()
        KeyboardResponder.dismiss()
      }
    InputField(text: $form.bio, title: "Short bio", note: "e.g. \"Camper and outdoor person during weekends\"", isValid: requiredValuesbinding(for: .bio))
    InputField(text: $form.username, title: "Username", isValid: requiredValuesbinding(for: .username))
  }
  
  @ViewBuilder private var birthdatePicker: some View {
    //  Use as wrapper for date picker saved date binding.
    //  This updates the @state dates and formats savedDate to birthdate string
    let dateProxy: Binding<Date?> = Binding(
      get: { savedDate },
      set: {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        savedDate = $0
        selectedDate = savedDate ?? Date()
        if let d = $0 {
          //birthdate = formatter.string(from: d)
          form.birthdate = formatter.string(from: d)
        }
      }
    )
    
    if showDatePicker {
      DatePickerCalendar(showDatePicker: $showDatePicker, savedDate: dateProxy, selectedDate: selectedDate)
    }
  }
  
  @ViewBuilder func buildPost() -> some View {
    switch profile {
    case .idle:
      Color.clear
    case .loaded(_):
      Color.clear
        .onAppear {
          if !isEditing {
            proceedToOnboarding = true
          } else {
            showAlert(title: "Profile updated", message: "")
            hasBeenEdited = true
            /// - IMPORTANT:  Revert to `.idle` after receiving response. We don't want the state to persist on next relayout.
            profile = .idle
          }
        }
    case .failed(let response):
      Color.clear.onAppear {
        showAlert(error: response)
        /// - IMPORTANT:  Revert to `.idle` after receiving response. We dont want the state to persist on next relayout.
        profile = .idle
      }
    case .isLoading(_, _):
      Color.black.opacity(0.05).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
}

// MARK: - Functions
extension CreateProfileScreen {
  //  Custom binding
  private func requiredValuesbinding(for key: CreateProfileForm.Field) -> Binding<Bool> {
    return Binding(get: {
      return form.requiredValues[key] ?? false
    }, set: {
      self.form.requiredValues[key] = $0
    })
  }
  //  Custom binding
  private func nonRequiredValuesBinding(for key: CreateProfileForm.Field) -> Binding<Bool> {
    return Binding(get: {
      return form.nonRequiredValues[key] ?? false
    }, set: {
      self.form.nonRequiredValues[key] = $0
    })
  }
  
  func showAlert(error: Error) {
    var alertTitle = "Something went wrong"
    var alertMessage = error.localizedDescription
    if let err = error.asAPIError {
      alertTitle = err.alert.title
      alertMessage = err.alert.message
    }
    showAlert(title: alertTitle, message: alertMessage)
  }
  
  func showAlert(title: String, message: String) {
    alert = (title: title, message: message)
    isPresentingAlert = true
  }
  
}

//  MARK: - API
extension CreateProfileScreen {
  func submit() {
    dependencies.interactors.profileInteractor.updateProfile(userId: form.userId,
                                                             firstName: form.firstName,
                                                             lastName: form.lastName,
                                                             username: form.username.lowercased(),
                                                             description: form.bio,
                                                             profileImageUrl: form.profileImageUrl,
                                                             birthdate: form.birthdate,
                                                             interestsIds: Array(form.selectedInterests),
                                                             profile: $profile)
  }
}

//  MARK: - Preview
struct CreateProfileScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CreateProfileScreen()
        .environmentObject(CreateProfileForm())
        .environment(\.editMode, .constant(.inactive))
    }
  }
}

//  MARK: - Signup form object
import Combine
class CreateProfileForm: ObservableObject {
  enum Field {
    case firstName, lastName, bio, birthdate, username, profileImageUrl
  }
  typealias InterestId = String
  @Published var userId = ""
  @Published var firstName = ""
  @Published var lastName = ""
  @Published var birthdate = ""
  @Published var bio = ""
  @Published var username = ""
  @Published var mobileNumber = ""
  @Published var mobileCountryCode = CountryCodeList.deviceLocale.phoneCode {
    didSet {
      //  Automatically set country based on mobile country code
      let noSymbolCountryCode = mobileCountryCode.replacingOccurrences(of: "+", with: "")
      mobileCountry = CountryCodeList.getCountry(isoCode: noSymbolCountryCode) ?? CountryCodeList.deviceLocale
    }
  }
  @Published var mobileCountry: Country = CountryCodeList.deviceLocale
  //  TODO: Store list of interests
  @Published var interests: [String] = []
  @Published var selectedInterests: Set<InterestId> = []
  //  TODO: Change to actual image url
  @Published var profileImageUrl = "" {
    didSet {
      //  Update required values validity state for profile image url
      nonRequiredValues[.profileImageUrl] = !profileImageUrl.isEmpty
    }
  }
  /// Store  all required fields and its valid state as value.
  /// If `true` the field is already valid and vice versa.
  @Published var requiredValues: [CreateProfileForm.Field: Bool] = [.firstName : false,
                                                                    .lastName : false,
                                                                    .bio : false,
                                                                    .username : false
  ]
  /// Store  all non-required fields and its valid state as value.
  /// If `true` the field is already valid and vice versa.
  @Published var nonRequiredValues: [CreateProfileForm.Field: Bool] = [.birthdate : false, .profileImageUrl: false]
  
  @Published var isValidAllRequiredValues = false
  private var cancelBag = CancelBag()
  
  private var validityPublisher: AnyPublisher<Bool, Never> {
    $requiredValues
      .map {
        $0.allSatisfy { $0.value == true }
      }
      .eraseToAnyPublisher()
  }
  
  init() {
    validityPublishing()
  }
  
  init(profile: User.Profile) {
    load(profile: profile)
  }
  
  func load(profile: User.Profile) {
    userId = profile.id
    firstName = profile.firstName
    lastName = profile.lastName
    username = profile.userName ?? ""
    bio = profile.description ?? ""
    birthdate = profile.birthDate ?? ""
    profileImageUrl = profile.profileImage?.originalUrl ?? ""
    mobileNumber = profile.mobileNumber ?? ""
    mobileCountryCode = profile.mobileCountryCode ?? ""
    validityPublishing()
  }
  
  private func validityPublishing() {
    validityPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.isValidAllRequiredValues, on: self)
      .store(in: cancelBag)
  }
}
