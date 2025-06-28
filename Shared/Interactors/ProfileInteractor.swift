//
//  ProfileInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 2/18/22.
//

import Foundation

class ProfileProductStore: ObservableObject {
  @Published var products: [Profile.Product] = []
  @Published var pagination = Pagination()
  @Published var shouldLoadMore = false
  private let loadMoreOffset = 1
  
  var hasNextPage: Bool {
    return nextPage != nil
  }
  
  var nextPage: Int? {
    guard pagination.current < pagination.total else { return nil }
    return pagination.current + 1
  }
  
  func isLastActivity(_ activity: Profile.Product) -> Bool {
    guard let last = products.last else { return false }
    return activity.id == last.id
  }
  
  func isFirstActivity(_ activity: Profile.Product) -> Bool {
    guard let first = products.first else { return false }
    return activity.id == first.id
  }
  
  func add(_ newProducts: [Profile.Product]) {
    products.append(contentsOf: newProducts)
  }
  
  func update(_ newProducts: [Profile.Product]) {
    products = newProducts
  }
}

//  MARK: - Store load more
extension ProfileProductStore {
  func loadMoreIfNeeded(current product: Profile.Product) {
    guard hasNextPage else { return }
    let thresholdIndex = products.index(products.endIndex, offsetBy: -loadMoreOffset)
    if products.firstIndex(where: { $0.id == product.id }) == thresholdIndex {
      shouldLoadMore = true
    }
  }
}

//  MARK: - Interactor
protocol ProfileInteractable {
  func load(userId: String, profile: LoadableSubject<Profile>)
  func productActivities(userId: String,
                         page: Int,
                         response: LoadableSubject<Profile.ProductActivities>,
                         store: ProfileProductStore)
  func updateProfile(userId: String, firstName: String, lastName: String, username: String?, description: String, profileImageUrl: String?, birthdate: String?, interestsIds: [String]?, profile: LoadableSubject<Profile>)
  func loadInterests(userId: String?, interests: LoadableSubject<Profile.Interests>)
}

extension ProfileInteractable {
  func loadInterests(interests: LoadableSubject<Profile.Interests>){
    self.loadInterests(userId: nil, interests: interests)
  }
}

struct ProfileInteractor: ProfileInteractable {
  let appState: AppState
  let api: ProfileAPI
  
  func load(userId: String, profile: LoadableSubject<Profile>) {
    let cancelBag = CancelBag()
    profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.get(userId: userId)
      .sinkToLoadable { result in
        profile.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func productActivities(userId: String,
                         page: Int,
                         response: LoadableSubject<Profile.ProductActivities>,
                         store: ProfileProductStore) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.getActivities(userId: userId, page: page)
      .sinkToLoadable { result in
        response.wrappedValue = result
        
        if let resultValue = result.value {
          let resultPage = resultValue.pagination?.current ?? 1
          //  We assume that if page is 1, we're starting all over
          if resultPage == 1 {
            store.update(resultValue.products)
          } else {
            store.add(resultValue.products)
          }
          
          if let pagination = resultValue.pagination {
            store.pagination = pagination
            print("store page is updated to \(store.pagination)")
          }
        }
        
      }
      .store(in: cancelBag)
  }
  
  func updateProfile(userId: String,
                     firstName: String,
                     lastName: String,
                     username: String?,
                     description: String,
                     profileImageUrl: String?,
                     birthdate: String?,
                     interestsIds: [String]?,
                     profile: LoadableSubject<Profile>) {
    
    let cancelBag = CancelBag()
    profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    // Compose body
    var requestBody: [String: Any] = [:]
    requestBody["first_name"] = firstName
    requestBody["last_name"] = lastName
    requestBody["description"] = description
    
    if let imageUrl = profileImageUrl, !imageUrl.isEmpty {
      requestBody["profile_image_url"] = profileImageUrl
    }
    
    if let bdate = birthdate, !bdate.isEmpty {
      requestBody["birth_date"] = bdate
    }
    
    if let username = username  {
      requestBody["user_name"] = username
    }
    
    if let interestsIds = interestsIds {
      requestBody["interest_ids"] = interestsIds
    }
        
    api.updateProfile(userId: userId, body: requestBody)
      .sinkToLoadable { result in
        profile.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func loadInterests(userId: String?, interests: LoadableSubject<Profile.Interests>) {
    let cancelBag = CancelBag()
    interests.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.getInterests(userId: userId)
      .sinkToLoadable { result in
        interests.wrappedValue = result
      }
      .store(in: cancelBag)
  }
}

struct StubProfileInteractor: ProfileInteractable {
  func loadInterests(userId: String?, interests: LoadableSubject<Profile.Interests>) {
    print("WARNING: Using stub StubProfileInteractor")
  }
  
  func load(userId: String, profile: LoadableSubject<Profile>) {
    print("WARNING: Using stub StubProfileInteractor")
  }
  
  func productActivities(userId: String, page: Int, response: LoadableSubject<Profile.ProductActivities>, store: ProfileProductStore) {
    print("WARNING: Using stub StubProfileInteractor")
  }
  
  func updateProfile(userId: String, firstName: String, lastName: String, username: String?, description: String, profileImageUrl: String?, birthdate: String?, interestsIds: [String]?, profile: LoadableSubject<Profile>) {
    print("WARNING: Using stub StubProfileInteractor")
  }
}
