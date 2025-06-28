//
//  ProfileScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/18/22.
//

import SwiftUI

struct ProfileScreen: View {
  @Environment(\.injected) private var dependencies: DIContainer
  /// - IMPORTANT:
  ///   - ACCESS THIS ONLY WHEN `profileScreenPresentation` environment value is `.tab`. `TabController` dependency is not passed when `ProfileScreen` is presented from a `.link`.
  @EnvironmentObject private var tabEnvironment: TabController
  
  /// Based on the env, the view decides on the ff:
  /// - When to use`TabController` or create its own link going to `ProductScreen`.
  /// - Show or hide action toolbar for invite and settings if the profile being viewed is also the logged in user. We only show the toolbar when presentation is `.tab`
  @Environment(\.profileScreenPresentation) private var screenPresentation
  /// State use for get profile
  @State private var profile: Loadable<Profile> = .idle
  /// State use for profile update on change of profile image.
  @State private var profilePhoto: Loadable<Profile> = .idle
  /// State use for get product activities
  @State private var productActivities: Loadable<Profile.ProductActivities> = .idle
  @State private var isPresentedShareSheet = false
  @State private var isPresentedInviteSheet = false
  @StateObject var activityStore = ProfileProductStore()
  /// Form that holds profile information from successful GET profile. This is passed to edit profile screen.
  @StateObject var profileForm = CreateProfileForm()
  @State private var isProfileEdited: Bool? = false
  /// Holds the profile image url from the server, used for comparing with form.profileImageUrl to identify if there's a new photo.
  @State private var serverProfileImageUrl = ""
  @State var isRefreshing = false
  private let productThumbnailColumn: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
  
  let userId: String
  
  init(userId: String, profile: Loadable<Profile> = .idle) {
    self.userId = userId
    _profile = State(initialValue: profile)
  }
  
  private var user: User.Profile? {
    return profile.value?.user
  }
  
  /// Returns `true` if the profile data belongs to the logged in user.
  private var isCurrentUser: Bool {
    guard let user = user else { return false }
    return dependencies.appState.userSession.userId == user.id
  }
  
  private var skeletonItems: [String] {
    var items: [String] = []
    for _ in 0..<9 {
      items.append(UUID().uuidString)
    }
    return items
  }
  
  var body: some View {
    PullToRefreshScrollView(isRefreshing: $isRefreshing) {
      VStack(alignment: .leading) {
        buildHeader()
        buildGallery()
          .padding(.horizontal, 20)
          .padding(.bottom, 20)
        if activityStore.hasNextPage {
          let _ = print("show loading state for next page")
          loadMoreIndicator
        }
      }
      .sheet(isPresented: $isPresentedInviteSheet) {
        ShareInviteView(code: user?.inviteCode ?? "", shareCopy: user?.inviteSpiel ?? "")
      }
    }
    
    .toolbar { navigationToolbar }
    
    .onChange(of: isRefreshing, perform: { newValue in
      print("is refreshing \(newValue)")
      if isRefreshing && !profile.isLoading && !productActivities.isLoading {
        refresh()
      }
    })
    
    .onChange(of: activityStore.shouldLoadMore, perform: { shouldLoadMore in
      print("should load: \(shouldLoadMore), request next page \(String(describing: activityStore.nextPage))")
      if shouldLoadMore && !productActivities.isLoading, let nextPage = activityStore.nextPage {
        loadProductActivities(page: nextPage)
        print("request next page")
      }
    })
    .onChange(of: profileForm.profileImageUrl, perform: { newValue in
      //  Safeguard: Check if new url is not the initial url.
      //  This helps avoid cases where profileImageUrl property is updated with the same
      if newValue != serverProfileImageUrl {
        updateProfilePhoto()
      }
    })
    .onAppear {
      print("profile on appear")
      
      if isProfileEdited ?? false {
        print("is profile edited \(String(describing: isProfileEdited))")
        load()
        isProfileEdited = false
      }
      
      switch profilePhoto {
      case .loaded(let result):
        //  Update property value with the latest profile image posted to the api.
        serverProfileImageUrl = result.user.profileImage?.largeUrl ?? ""
        print("profile update with new photo is successful")
      case .failed:
        // TODO: server profile photo update failed. Revert to old photo
        break
      default:
        break
      }
    }
    .navigationBarHidden(false)
    .navigationTitle(user?.fullName ?? "")
    .navigationBarTitleDisplayMode(.inline)
  }
}

//  MARK: - View
extension ProfileScreen {
  @ViewBuilder func buildHeader() -> some View {
    switch profile {
    case .idle:
      Color.clear
        .onAppear {
          load()
        }
    case .loaded(let result):
      //  Update UI
      header(user: result.user)
        .onAppear {
          //  Fill form with profile data
          serverProfileImageUrl = result.user.profileImage?.largeUrl ?? ""
          profileForm.load(profile: result.user)
          isRefreshing = false
        }
    case .failed(_):
      headerSkeleton
    case .isLoading(_, _):
      headerSkeleton
    }
  }
  
  @ToolbarContentBuilder
  var navigationToolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if isCurrentUser && screenPresentation == .tab {
        //  Settings
        NavigationLink {
          SettingsScreen().environmentObject(profileForm)
        } label: { Image.asset(.ic_settings).icon() }
      }
    }
    
    //  Invite code
    ToolbarItemGroup(placement: .navigationBarLeading) {
      if isCurrentUser && screenPresentation == .tab {
        Button {
          isPresentedInviteSheet = true
        } label: { Image.asset(.ic_person_add).icon() }
      }
    }
  }

  @ViewBuilder func buildGallery() -> some View {
    switch productActivities {
    case .idle:
      Color.clear
        .onAppear {
          loadProductActivities(page: 1)
        }
    case .loaded(let result):
      if result.products.isEmpty {
        // TODO: Add empty state view.
        Color.clear
      } else {
        productThumbnails
          .onAppear {
            let _ = print("profile loaded data")
            activityStore.shouldLoadMore = false
            isRefreshing = false
          }
      }
    case .failed(let response):
      VStack {
        Spacer()
        Text(parseToErrorCopy(using: response))
          .fontBold(size: 14)
          .fgAssetColor(.black).opacity(0.4)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 20)
        Spacer()
      }
      .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.3)
    case .isLoading(_, _):
      if activityStore.shouldLoadMore {
        productThumbnails
      } else {
        gallerySkeleton
      }
    }
  }
  
  @ViewBuilder var productThumbnails: some View {
    LazyVGrid(columns: productThumbnailColumn) {
      ForEach(activityStore.products) { product in
        productThumbnail(for: product)
          .onAppear {
            activityStore.loadMoreIfNeeded(current: product)
          }
      }
    }
  }
  
  @ViewBuilder private func productThumbnail(for product: Profile.Product) -> some View {
    switch screenPresentation {
    case .tab:
      thumbnailImage(url: product.image.largeUrl, sentiment: Sentiment.parse(product.kind))
      .onTapGesture {
        tabEnvironment.goToProduct(id: product.id, reviewId: product.reviewId)
      }
    case .link:
      NavigationLink {
        ProductScreen(id: product.id, reviewId: product.reviewId)
      } label: {
        thumbnailImage(url: product.image.largeUrl, sentiment: Sentiment.parse(product.kind))
      }
      .appButtonStyle(.flatLink)
    }
  }
  
  private func thumbnailImage(url: String, sentiment: Sentiment?) -> some View {
    ImageRender(urlPath: url, placeholderRadius: 8) { image in
      image.thumbnail()
    }
    .overlay(buildOverlay(sentiment: sentiment), alignment: .bottomTrailing)
    .cornerRadius(8)
  }
  
  @ViewBuilder func buildOverlay(sentiment: Sentiment?) -> some View {
    if let sentiment = sentiment {
      switch sentiment {
      case .love:
        LoveImage()
          .frame(width: 20, height: 20)
          .offset(x: -10, y: -10)
      case .hate:
        HateImage()
          .frame(width: 20, height: 20)
          .offset(x: -10, y: -10)
      }
    }
  }
  
  private func header(user: User.Profile) -> some View {
    VStack(alignment: .center) {
      HStack(alignment: .top, spacing: 20) {
        //  Enable editing photo only when viewing in tab.
        if isCurrentUser && screenPresentation == .tab {
          ProfileImage(imageUrl: $profileForm.profileImageUrl, size: .init(width: 86, height: 86), actionIconConfiguration: .normal)
        } else {
          ImageRender(urlPath: profileForm.profileImageUrl) { image in
            image.thumbnail()
          }
          .modifier(CircleClip(size: 86))
        }
        
        VStack(alignment: .leading, spacing: 10) {
          Text(user.fullName)
            .fontHeavy(size: 20)
          Text(user.atUsername.lowercased())
            .fontRegular(size: 14)
            .offset(y: -6)
          Text(user.description ?? "")
            .fontRegular(size: 14)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
          HStack (alignment: .center, spacing: 16) {
            if isCurrentUser {
              editProfileLink
            }
            shareButton
          }
          .padding(.top, 10)
          .buttonStyle(.plain)
        }
        Spacer()
      }
      .padding(20)
      
      Divider()
      
      if user.loveCount > 0 || user.hateCount > 0 {
        SentimentDisplay(size: .large, love: String(user.loveCount), hate: String(user.hateCount))
          .padding(20)
      }
    }
    .activitySheet(present: $isPresentedShareSheet, items: [user.shareableProfileUrl ?? ""], excludedActivityTypes: nil)
  }
  
  private var editProfileLink: some View {
    NavigationLink {
      CreateProfileScreen(hasBeenEdited: $isProfileEdited)
        .environmentObject(profileForm)
        .environment(\.editMode, .constant(.active))
    } label: {
      Text("Edit profile")
        .fontBold(size: 14)
        .fgAssetColor(.black)
        .padding(.vertical, 7)
        .padding(.horizontal, 14)
        .addBorder(color: .black, cornerRadius: 8)
    }
  }
  
  private var shareButton: some View {
    Button {
      isPresentedShareSheet = true
    } label: {
      Label("Share", systemImage: "square.and.arrow.up")
        .imageScale(.large)
        .fontBold(size: 14)
    }
  }
  
  private var headerSkeleton: some View {
    HStack(spacing: 20) {
      Circle().frame(width: 86, height: 86)
      VStack(alignment: .leading) {
        Rectangle().frame(width: 230, height: 12)
        Rectangle().frame(width: 200, height: 12)
        Rectangle().frame(width: 170, height: 12)
      }
    }
    .foregroundColor(Color(.secondarySystemBackground))
    .padding(20)
  }
  
  @ViewBuilder private var gallerySkeleton: some View {
    LazyVGrid(columns: productThumbnailColumn) {
      ForEach(skeletonItems, id: \.self) {_ in
        ThumbnailPlaceholder()
      }
    }
  }
  
  private var loadMoreIndicator: some View {
    HStack {
      Spacer()
      ProgressView()
      Spacer()
    }
  }
}

// MARK: - API
extension ProfileScreen {
  func load() {
    dependencies.interactors.profileInteractor.load(userId: userId, profile: $profile)
  }
  
  func loadProductActivities(page: Int) {
    dependencies.interactors.profileInteractor
      .productActivities(userId: userId,
                         page: page,
                         response: $productActivities,
                         store: activityStore)
  }
  
  func refresh() {
    load()
    loadProductActivities(page: 1)
  }
  
  func updateProfilePhoto() {
    print("update profile photo using all profile data")
    dependencies.interactors.profileInteractor.updateProfile(userId: profileForm.userId,
                                                             firstName: profileForm.firstName,
                                                             lastName: profileForm.lastName,
                                                             username: profileForm.username.lowercased(),
                                                             description: profileForm.bio,
                                                             profileImageUrl: profileForm.profileImageUrl,
                                                             birthdate: profileForm.birthdate,
                                                             interestsIds: Array(profileForm.selectedInterests),
                                                             profile: $profilePhoto)
  }
 
  // MARK: - Function
  func signout() {
    dependencies.appState.removeUserSession()
    dependencies.appState.updateRoot(.entry)
  }
  
  private func parseToErrorCopy(using response: Error) -> String {
    var title = "Something went wrong"
    var message = response.localizedDescription
    if let err = response.asAPIError {
      title = err.alert.title
      message = err.alert.message
    }
    return "\(title)\n\(message)"
  }
}


struct ProfileScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ProfileScreen(userId: "1234", profile: .loaded(Profile.seed))
    }
  }
}


//  MARK: - Environment
struct ProfilePresentationKey: EnvironmentKey {
  static var defaultValue: Mode = .tab
  enum Mode {
    //  When opened as a tab
    case tab
    //  When opened as a link
    case link
  }
}
//  MARK: Values
extension EnvironmentValues {
  var profileScreenPresentation: ProfilePresentationKey.Mode {
    get { self[ProfilePresentationKey.self] }
    set { self[ProfilePresentationKey.self] = newValue }
  }
}
