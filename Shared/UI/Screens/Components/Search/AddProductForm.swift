//
//  AddProductForm.swift
//  Dash
//
//  Created by Steffi Tan on 2/17/22.
//

import SwiftUI

struct AddProductForm: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject var searchEnvironment: SearchEnvData
  @Environment(\.searchPresentation) var searchPresentation
  
  @State var text = ""
  @State var isEditing = false
  @State var lookupPreview: Loadable<Search.Lookup> = .idle
  @State var newProduct: Loadable<Product> = .idle
  @State var willUseInProgressCTA = false
  @State var proceedToOnboardingProduct = false
  
  @State private var isPresentedPreviewAlert = false
  @State private var isPresentedAddAlert = false
  @State private var alert: (String, String)?
  
  var body: some View {
    ZStack {
      VStack(alignment: .center) {
        labels
        field
          .overlay(content: {
            if isEditing {
              clearButton
            }
          })
          .padding(.vertical, 20)
          .onTapGesture {
            isEditing = true
          }
        
        buildPreview()
          .alert(isPresented: $isPresentedPreviewAlert) {
            Alert(title: Text(alert?.0 ?? ""),
                  message: Text(alert?.1 ?? ""),
                  dismissButton: .default(Text("OK"), action: {
            }))
          }
        
        if willUseInProgressCTA {
          progressButton
        } else {
          ctaButton
            .alert(isPresented: $isPresentedAddAlert) {
              Alert(title: Text(alert?.0 ?? ""),
                    message: Text(alert?.1 ?? ""),
                    dismissButton: .default(Text("OK"), action: {
              }))
            }
        }
      }
      .onChange(of: text, perform: fieldTextChanged(text:))
      //  TODO: Scale padding
      .padding(30)

      buildSubmitPlaceholder()
      
      NavigationLink(isActive: $proceedToOnboardingProduct) {
        OnboardingProductScreen(id: newProduct.value?.id ?? "")
          .inject(dependencies)
      } label: {
        EmptyView()
      }
    }
  }

  //  MARK: - Helper
  private func fieldTextChanged(text: String) {
    if !text.isEmpty {
      lookup()
    }
  }
}

// MARK: - Views and Builders
extension AddProductForm {
  private var ctaButton: some View {
    Button("Create this product") {
      submit()
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 12)
    .fontBold(size: 16)
    .bgAssetColor(.purple)
    .foregroundColor(.white)
    .cornerRadius(8)
    .padding(20)
  }
  
  private var progressButton: some View {
    Button {
      print("do nothing")
    } label: {
      ProgressView()
    }
    .disabled(true)
    .padding(.horizontal, 24)
    .padding(.vertical, 10)
    .background(Color.purple.opacity(0.4))
    .foregroundColor(.white)
    .cornerRadius(8)
    .padding(20)
  }
  
  private var labels: some View {
    VStack(spacing: 10) {
      Text("Sorry, we couldn’t find it")
        .fontBold(size: 20)
      Text("Would you like to add this product?")
        .fontRegular(size: 16)
    }
    .fgAssetColor(.black)
  }
  
  private var field: some View {
    TextField("Copy and paste a product page link", text: $text)
      .fontRegular(size: 14)
      .fgAssetColor(.black)
      .padding(10)
      .bgAssetColor(.gray_1)
      .cornerRadius(8)
      .padding(.vertical, 20)
  }
  
  private var clearButton: some View {
    HStack(alignment: .center) {
      Spacer()
      Button(action: {
        self.text = ""
        isEditing = false
        lookupPreview = .idle
      }) {
        Image(systemName: "multiply.circle.fill")
          .foregroundColor(.gray)
          .padding(.trailing, 8)
      }
    }
  }

  @ViewBuilder func buildPreview() -> some View {
    switch lookupPreview {
    case .idle:
      EmptyView()
        .background(Color.clear)
    case .loaded(let result):
      if let preview = result.preview, result.error == nil {
        // Product
        HStack(alignment: .center, spacing: 18) {
          ImageRender(urlPath: preview.imageUrl ?? "",
                      placeholderRadius: 8) { image in
            image.thumbnail()
          }.modifier(SquareFrame(size: 94, cornerRadius: 8))
          
          VStack(alignment: .leading, spacing: 8) {
            Text(preview.displayName ?? "")
              .fontRegular(size: 16)
              .fgAssetColor(.black)
              .lineLimit(5)
              .multilineTextAlignment(.leading)
              .padding(.leading, 0)
          }
          Spacer()
        }
      } else {
        Text("cant get preview")
      }
    case .failed(let error):
      Color.clear.onAppear {
        isPresentedPreviewAlert = true
        alert = ("Something went wrong", error.localizedDescription)
        if let err = error.asAPIError {
          alert = (err.alert.title, err.alert.message)
        }
      }.frame(width: 0, height: 0)
    case .isLoading(_, _):
      ProgressView()
    }
  }
  
  @ViewBuilder func buildSubmitPlaceholder() -> some View {
    switch newProduct {
    case .idle:
      Color.clear
    case .loaded(let result):
      Color.clear
        .onAppear {
          switch searchPresentation {
          case .onboarding:
            proceedToOnboardingProduct = true
          case .sheet, .fullScreen:
            searchEnvironment.tab?.goToProduct(id: result.id)
          }
        }
    case .failed(let error):
      Color.clear
        .onAppear {
          willUseInProgressCTA = false
          isPresentedPreviewAlert = true
          alert = ("Something went wrong", error.localizedDescription)
          if let err = error.asAPIError {
            alert = (err.alert.title, err.alert.message)
          }
        }.frame(width: 0, height: 0)
    case .isLoading(_, _):
      Color.clear
        .onAppear {
          willUseInProgressCTA = true
        }
    }
  }
}

// MARK: - API
extension AddProductForm {
  func lookup() {
    dependencies.interactors.searchInteractor.lookUp(url: text, result: $lookupPreview)
  }
  
  func submit() {
    guard let product = lookupPreview.value?.preview else { return }
    dependencies.interactors.productInteractor.create(displayName: product.displayName ?? "",
                                                      imageUrl: product.imageUrl ?? "",
                                                      externalUrl: text,
                                                      result: $newProduct)
  }
}

struct AddProductForm_Previews: PreviewProvider {
  static var previews: some View {
    AddProductForm()
  }
}
