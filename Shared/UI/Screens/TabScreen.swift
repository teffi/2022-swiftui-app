//
//  TabScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/24/22.
//

import SwiftUI

struct TabScreen: View {
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  private let container: DIContainer
  @StateObject private var controller = TabController()
  @StateObject private var searchEnv = SearchEnvData()
  
  
  init(container: DIContainer) {
    self.container = container
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      TabView(selection: $controller.activeTab) {
        homeTab
        searchTab
        if let userId = container.appState.userSession.userId {
          userTab(userId: userId)
        } else {
          Text("Screen for logged out user")
        }
      }
      
      // Use custom tabbarview for better control on the UI
      tabBarView

      //  -- Add navigation links that we will present in full screen without the tabbar
      //  (1) Product screen
      NavigationLink(isActive: $controller.isPresentedProduct) {
        ProductScreen(id: controller.selectedProductId ?? "no product id",
                      reviewId: controller.selectedProductReviewId,
                      questionId: controller.searchQuestion?.id)
          .inject(container)
      } label: { EmptyView() }

      //  Search sheet
      .sheet(isPresented: $controller.isPresentedSearch, onDismiss: {
        // IMPORTANT: Reset search question when search sheet is dismissed
        controller.searchQuestion = nil
      }) {
        // View presented on the sheet
        SearchSheet()
          .environmentObject(searchEnv)
          .inject(container)
      }
    }
    //  Avoid being pushed up when keyboar appears.
    //  If this is removed, whenever keyboard appears on any tab child,
    //  tabbarview will be pushed up on to the top of the keyboard.
    .ignoresSafeArea(.keyboard)
    .navigationTitle("") // When any sheet controller is presented, uinavigation controller sets the root navbar to visible. TODO: find way to reset.
    .navigationBarHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .environmentObject(controller)
    .onAppear {
      print("rendering tab screen on appear")
      searchEnv.tab = controller
    }  }
}

//  MARK: - Tab views
extension TabScreen {
  /// Home
  private var homeTab: some View {
    NavigationView {
      let _ = print("nav link: rendering feed")
      FeedScreen()
        .inject(container)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
    .navigationViewStyle(.stack)
    .tag(Tab.home)
  }
  
  /// Search
  private var searchTab: some View {
    Text("Show search")
      .tag(Tab.search)
  }
  
  private func userTab(userId: String) -> some View {
    NavigationView {
      let _ = print("nav link: rendering profile")
      ProfileScreen(userId: userId)
        .inject(container)
        .navigationBarTitleDisplayMode(.inline)
    }
    .navigationViewStyle(.stack)
    .tag(Tab.user)
  }
  
  var tabBarView: some View {
    VStack(spacing: 0) {
      Divider()
      HStack {
        tabItemIcon(for: .home, isActive: controller.activeTab == .home)
        Spacer()
        tabItemIcon(for: .search)
        Spacer()
        tabItemIcon(for: .user, isActive: controller.activeTab == .user)
      }
      // TODO: Scale horizontal padding
      .padding(.horizontal, 40)
    }
    .padding(.bottom, safeAreaInsets.bottom == 0 ? 20 : 0)
    .background(Color.white.ignoresSafeArea())
  }
}

extension TabScreen {
  @ViewBuilder private func tabItemIcon(for tab: Tab, isActive: Bool = false) -> some View {
    VStack {
      switch tab {
      case .home:
        Image.asset(isActive ? .ic_home_fill : .ic_home_outline)
          .icon()
          .padding(6)
      case .search:
        Image.asset(.ic_plus_gradient)
          .icon()
      case .user:
        Image.asset(isActive ? .ic_account_circle_fill : .ic_account_circle_outline)
          .icon()
          .padding(6)
      }
    }
    .frame(width: 65, height: 42)
    .padding(.top, 12)
    .onTapGesture {
      controller.open(tab)
    }
  }
}

struct TabScreen_Previews: PreviewProvider {
  static var previews: some View {
    TabScreen(container: .preview)
  }
}

// MARK: - TabController

class TabController: ObservableObject {
  /// Holds the current active tab
  /// On select search  we preserved the previously selected tab because search tab item will show a sheet.
  @Published var activeTab = Tab.home {
    didSet {
      //  If selected tab is search, revert back to the previously selected tab
      //  Ref: https://stackoverflow.com/questions/60394201/tabbar-middle-button-utility-function-in-swiftui
      if activeTab == .search {
        print("did select search tab")
        isPresentedSearch = true
        activeTab = oldValue
      }
    }
  }
  /// Binded to `TabRootScreen.Home` navigation link for activating and deactivating to product page.
  /// If set to false, tab screen navigation will react and will pop back to Home.
  @Published var isPresentedProduct: Bool = false
  
  /// `true` on search tab item select.
  /// - Important: On select search  we preserved the previously selected tab because search tab item will show a sheet.
  /// - Note: Binded to TabScreen sheet presentation
  @Published var isPresentedSearch = false
  
  /// Holds the search question data
  var searchQuestion: SearchEnvData.Question?
  
  /// Holds the product id of the product page destination.
  private(set) var selectedProductId: String?
  /// Holds the review id of the product page destination.
  private(set) var selectedProductReviewId: String?
  
  func open(_ tab: Tab) {
    activeTab = tab
  }
  
  func goToSearch(question: SearchEnvData.Question? = nil) {
    searchQuestion = question
    isPresentedSearch = true
  }
  
  func goToProduct(id: String, reviewId: String? = nil) {
    isPresentedSearch = false
    isPresentedProduct = true
    
    selectedProductId = id
    selectedProductReviewId = reviewId
    //  TODO: Investigate - Temporarily disabled until fixed
    //  Autoselect home tab if going to product
    //  Bug: App loses existing navigation stack of other tab. See comment in TabRootScreen.
    //    if activeTab != .home {
    //      activeTab = .home
    //    }
  }
}
