//
//  PhotoViewer.swift
//  Dash
//
//  Created by Steffi Tan on 3/24/22.
//

import SwiftUI
import URLImage
import Combine

class PhotoStore: ObservableObject {
  struct ImageAttributes: Identifiable {
    var id: String {
      return url
    }
    let url: String
    var uiImage: UIImage?
  }
  
  @Published var images: [PhotoStore.ImageAttributes] = []
  
  init(imageUrls: [String]) {
    var imageCache: [PhotoStore.ImageAttributes] = []
    imageUrls.forEach { url in
      imageCache.append(.init(url: url, uiImage: nil))
    }
    images = imageCache
  }
  
  func getImageIndex(id: String) -> Int {
    return images.firstIndex { $0.id == id } ?? 0
  }
}

struct PhotoViewer: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.urlImageService) var service: URLImageService
  
  @StateObject var store: PhotoStore
  @State private var selectedImageUrl: String
  
  init(imageUrls: [String], startIndex: Int? = nil) {
    _store = StateObject(wrappedValue: PhotoStore(imageUrls: imageUrls))
    let index = startIndex ?? 0
    _selectedImageUrl = State(initialValue: imageUrls[safe: index] ?? "")
  }
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      TabView(selection: $selectedImageUrl) {
        ForEach(store.images) { attribute in
          ImageZoomCanvas(inputImage: storeImageBinding(for: attribute.id),
                         imageAttributes: ImageCrop.ImageAttributes())
            .tag(attribute.url)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .always))
      .background(Color.black.ignoresSafeArea())
      closeButton
    }
    .onAppear(perform: {
      print("on appear, downloading images")
      //  TODO: For better sanity, add checking to avoid re-downloading
      //  Currently safe to use because URLImageService caches image.
      store.images.forEach { attributes in
        downloadImage(url: URL(string: attributes.url)!)
      }
    })
    .navigationBarHidden(true)
  }
  
  //MARK: - Views
  private var closeButton: some View {
    Button {
      presentationMode.wrappedValue.dismiss()
    } label: {
      Image(systemName: "xmark")
        .imageScale(.large)
        .fgAssetColor(.white)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
  }
}

//  MARK: - Functions
extension PhotoViewer {
  /// Downloads image and sync received image to `PhotoStore`
  /// - Parameter url:
  func downloadImage(url: URL) {
    let cancelBag = CancelBag()
    service.remoteImagePublisher(url, identifier: nil)
      .tryMap { $0.cgImage }
      .catch { _ in
        Just(nil)
      }
      .sink { image in
        if let cgImage = image {
          store.images[store.getImageIndex(id: url.absoluteString)].uiImage = UIImage(cgImage: cgImage)
        }
      }
      .store(in: cancelBag)
  }
  
  /// Wrap `PhotoStore.images.uiImage` to a binding property
  /// - Parameter id: image id or url
  /// - Returns
  private func storeImageBinding(for id: String) -> Binding<UIImage?> {
    return Binding(get: {
      return store.images[store.getImageIndex(id: id)].uiImage
    }, set: {
      self.store.images[store.getImageIndex(id: id)].uiImage = $0
    })
  }
}

struct PhotoViewer_Previews: PreviewProvider {
  static var previews: some View {
    PhotoViewer(imageUrls: ["https://picsum.photos/400/500"])
  }
}
