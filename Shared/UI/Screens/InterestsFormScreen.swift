//
//  InterestsFormScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/22/22.
//

import SwiftUI

struct InterestsFormScreen: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject var form: CreateProfileForm
  
  @State var profile: Loadable<Profile> = .idle
  @State var interests: Loadable<Profile.Interests> = .idle
  @State var proceedToOnboarding = false
  
  var body: some View {
    ZStack {
      VStack {
        ScrollView(.vertical) {
          VStack(alignment: .leading, spacing: 32) {
            Text("Select some of your interests this will help us recommend you related products in the future.")
              .fontRegular(size: 14)
              .foregroundColor(Color.black.opacity(0.4))
            buildContent()
          }
          .padding(20)
        }
        
        finishBtn
          .padding(.horizontal, 20)
        
        NavigationLink(isActive: $proceedToOnboarding) {
          OnboardingSearchScreen(name: form.firstName)
            .inject(dependencies)
        } label: {
          EmptyView()
        }
      }
      
      buildPost()
    }
    .navigationTitle("Add Interests")
    .navigationBarHidden(false)
    .onAppear {
      print("signup form user id \(form.userId), first name: \(form.firstName)")
    }
  }
}

//  MARK: - View
extension InterestsFormScreen {
  @ViewBuilder func buildContent() -> some View {
    switch interests {
    case .idle:
      Color.clear
        .onAppear {
          loadInterests()
        }
    case .loaded(let result):
      ForEach(result.interests) { interest in
        buildInterest(header: interest.name, items: interest.items)
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
      contentSkeleton
    }
  }
  
  @ViewBuilder func buildPost() -> some View {
    switch profile {
    case .idle:
      Color.clear
    case .loaded(_):
      Color.clear
        .onAppear {
          proceedToOnboarding = true
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
  
  @ViewBuilder private func buildInterest(header: String, items: [Interest.Item]) -> some View {
    VStack(alignment: .leading) {
      Text(header)
        .fontHeavy(size: 20)
        .fgAssetColor(.black)
      WrappingHStack(models: items, viewGenerator: { item in
        TagButton(title: item.name,
                  isSelected: form.selectedInterests.contains { $0 == item.id}) { isSelected in
          
          if let existingIndex = form.selectedInterests.firstIndex(where: { $0 == item.id }) {
            form.selectedInterests.remove(at: existingIndex)
          } else {
            form.selectedInterests.insert(item.id)
          }
        }
      }, horizontalSpacing: 4, verticalSpacing: 4)
        .padding(0)
        .padding(.bottom, 12)
    }
  }
  
  @ViewBuilder private var contentSkeleton: some View {
    ForEach(1..<4) { _ in
      let width = CGFloat(Int.random(in: 110 ..< 250))
      VStack(alignment: .leading) {
        Rectangle().frame(width: 100, height: 12)
        WrappingHStack(models: .init(repeating: "", count: 10), viewGenerator: { item in
          Rectangle().frame(width: width, height: 12)
        }, horizontalSpacing: 0, verticalSpacing: 4)
          .padding(0)
          .padding(.bottom, 12)
      }
      .foregroundColor(Color(.secondarySystemBackground))
    }
  }
  
  @ViewBuilder private var finishBtn: some View {
    HStack {
      Spacer()
      Button("Finish") {
        submit()
      }
      .appButtonStyle(.primary)
    }
  }
}

//  MARK: - API
extension InterestsFormScreen {
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
  
  func loadInterests() {
    dependencies.interactors.profileInteractor.loadInterests(interests: $interests)
  }
}

struct InterestsFormScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      InterestsFormScreen()
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(CreateProfileForm())
    }
  }
}


