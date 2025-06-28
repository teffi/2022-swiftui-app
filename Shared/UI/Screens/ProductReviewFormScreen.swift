//
//  ProductReviewFormScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/11/22.
//

import SwiftUI
import Introspect
import Cloudinary
import URLImage
import Combine

//  MARK: - Review form product details
/// Object that holds data needed on ProductReviewFormScreen to properly render and process posting of review
class ProductReviewForm: ObservableObject {
  typealias ReviewImageAttributes = ProductReviewForm.ImageAttributes
  
  var questionId: String? = nil
  @Published var reviewId: String?
  @Published var body = ""
  @Published var sentiment: Sentiment = .love
  @Published var images: [ReviewImageAttributes] = []
  @Published var imagesUrls: [String: String?] = [:]
  //  Returns all valid `imageUrls` in array format.
  var validImageUrls: [String]? {
    return Array(imagesUrls.compactMapValues { $0 }.values)
  }
  
  init(questionId: String? = nil) {
    self.questionId = questionId
  }
  
  init(review: Review) {
    updateReview(with: review)
  }
  
  func updateReview(with review: Review) {
    reviewId = review.id
    body = review.body
    sentiment = Sentiment(rawValue: review.kind) ?? .love
    review.images?.forEach({ imageset in
      let image = ReviewImageAttributes(uiImage: nil, isUploading: false)
      images.append(image)
      /// - IMPORTANT:Use original url in forms because the server only identifies if the images are unchanged using the original image url.
      imagesUrls[image.id] = imageset.originalUrl
      print("review form images \(imagesUrls)")
    })
  }
  
  struct ImageAttributes: Identifiable {
    let id: String = UUID().uuidString
    var uiImage: UIImage? = nil
    var isUploading: Bool = false
    var image: Image? {
      guard let uiImage = uiImage else { return nil }
      return Image(uiImage: uiImage)
    }
  }
  
  @discardableResult
  /// Add `ImageAttributes` containing the provided `uiImage` to `images` array
  /// - Parameter uiImage:
  /// - Returns: Discardable `ImageAttributes`
  func addImage(uiImage: UIImage) -> ImageAttributes {
    let attributes = ImageAttributes(uiImage: uiImage)
    images.append(attributes)
    return attributes
  }
  
  /// Updates url string of provided `imageId` in `uploadImages`
  /// - Parameters:
  ///   - imageId:
  ///   - url:
  func update(imageId: String, url: String) {
    imagesUrls[imageId] = url
  }
  
  func updateUpload(imageId: String, state: Bool) {
    if let index = images.firstIndex(where: { $0.id == imageId }) {
      images[index].isUploading = state
    }
  }
  
  /// Remove item entry in `images` and `uploadedImages` matching the provided image id.
  /// - Parameter imageId:
  func remove(imageId: String) {
    //  Remove from images
    if let index = images.firstIndex(where: { $0.id == imageId }) {
      images.remove(at: index)
    }
    // Remove from uploaded images
    imagesUrls[imageId] = nil
  }
  
  func getImageIndex(id: String) -> Int {
    return images.firstIndex { $0.id == id } ?? 0
  }
}


//  MARK: - ProductReviewFormScreen
struct ProductReviewFormScreen: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.editMode) private var editMode
  @Environment(\.onboardingForm) private var isOnboarding
  @Environment(\.urlImageService) var service: URLImageService
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject var productEnv: ProductEnv
  @ObservedObject var form: ProductReviewForm
  //  Bindings
  @State private var isTextViewOnFocus = false
  @State var remainingCharCount: Int
  @State var post: Loadable<Review.PostResponse> = .idle
  @State var isPresentedConfirmation = false
  //  Images
  /// Selected image from either `Camera` or `ImagePicker`
  @State private var inputImage: UIImage?
  /// Actionsheet to choose photo source - Camera or Photo Picker
  @State private var showPhotoOptionSheet = false
  /// Present `Camera` in a fullscreen sheet
  @State private var showCamera = false
  /// Present `ImagePicker` in a sheet
  @State private var showPhotoPicker = false
  private let imageDownloaderCancelBag = CancelBag()
  private var maxImageCount = 4
  private var didReachMaxImageUploads: Bool {
    return form.images.count >= maxImageCount
  }
  
  //  Settings
  private var minimumCharacters = 150
  //  Toolbar height used as bottom padding value to avoid collision with TextView
  private var formToolbarHeight: CGFloat = 50
  
  var isEditing: Bool {
    return editMode?.wrappedValue.isEditing ?? false
  }
  
  init(form: ProductReviewForm) {
    _remainingCharCount = State(initialValue: max(0, minimumCharacters - form.body.count))
    _post = State(initialValue: .idle)
    _form = ObservedObject(wrappedValue: form)
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        productInfo
        thumbnails
        textView
          .onChange(of: form.body, perform: { newValue in
            //print("change text value \(text)")
            remainingCharCount = max(0, minimumCharacters - form.body.count)
          })
          .padding(.vertical, 10)
      }
      .padding(.init(top: 20,
                     leading: 20,
                     bottom: formToolbarHeight,
                     trailing: 20))
      .introspectTextView(customize: { textView in
        //  Add a little delay in showing keyboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          textView.becomeFirstResponder()
        }
      })
      
      //  Photo source
      .actionSheet(isPresented: $showPhotoOptionSheet, content: {
        photoSourceActionSheet
      })
      // Photo Picker
      .sheet(isPresented: $showPhotoPicker) {
        ImagePicker(image: $inputImage)
      }
      //  Camera
      .fullScreenCover(isPresented: $showCamera) {
        Camera(selectedImage: $inputImage)
          .ignoresSafeArea()
      }
      
      characterCountView.padding(12)
      
      buildPost()
    }
    //  TODO: Change to custom view.
    .alert(isPresented: $isPresentedConfirmation) {
      Alert(title: Text(isEditing ? "Update successful" : "Submission successful"),
            message: nil,
            dismissButton: .default(Text("OK"), action: {
        
        print("review form is onboarding env \(isOnboarding)")
        //  If in onboarding workflow, just return to tab root.
        //  No need invalidate or go to previous screen
        if isOnboarding {
          dependencies.appState.updateRoot(.tab)
        } else {
          // Pop view and refresh product data
          productEnv.invalidateData()
          presentationMode.wrappedValue.dismiss()
        }
      }))
    }
    
    .toolbar { submitSaveToolbar }
    .onChange(of: inputImage) { newValue in
      uploadAndDisplayImage()
    }
    .onAppear {
      print("review form appear")
      form.imagesUrls.forEach { key, value in
        downloadImage(url: URL(string: value ?? "")!, id: key)
      }
    }
    .navigationTitle(isEditing ? "Update review" : "Write review")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarHidden(false)
  }
  
}
//  MARK: - Views
extension ProductReviewFormScreen {
  @ViewBuilder private var productInfo: some View {
    HStack(alignment: .center, spacing: 18) {
      ImageRender(urlPath: productEnv.product?.image.mediumUrl ?? "", placeholderRadius: 8) { image in
        image.thumbnail()
      }
      .modifier(SquareFrame(size: 94, cornerRadius: 8))
      .overlay(sentimentOverlay, alignment: .bottomTrailing)
      
      VStack(alignment: .leading, spacing: 12) {
        Text(productEnv.product?.displayName ?? " ")
          .lineLimit(3)
          .fontHeavy(size: 16)
          .fgAssetColor(.black)
          .fixedSize(horizontal: false, vertical: true) //<- when removed, ios14 does not render in multiplelines
          .multilineTextAlignment(.leading)
          .padding(.leading, 0)
      }
      //  Add spacer to fill up unused width space and elements will stick on the leading edge
      Spacer()
    }
  }
  
  private var sentimentOverlay : some View {
    Button {
      print("sentiment select")
      // Update sentiment with the opposite of its current value. .love becomes .hate and vice versa.
      form.sentiment = form.sentiment.toggle()
    } label: {
      Image(form.sentiment.iconName)
        .icon()
        .frame(width: 20, height: 20)
    }
    .padding([.bottom, .trailing], 6)
  }
  
  @ToolbarContentBuilder
  var submitSaveToolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button(isEditing ? "Save" : "Submit") {
        if isEditing {
          saveEdit()
        } else {
          submit()
        }
      }
      .appButtonStyle(.primaryText)
      .disabled(remainingCharCount >= 1)
    }
  }
  
  //  TODO: Add Auto focus on Textview package
  @ViewBuilder private var textView: some View {
    TextView($form.body)
      .enableScrolling(true)
      .disableAutocorrection(true)
      .placeholder("Write your review") { view in
        view.foregroundColor(.gray)
      }
      .fontRegular(size: 20)
      .fgAssetColor(.black)
  }
  
  private var characterCountView: some View {
    //  Custom view that acts a form toolbar
    HStack {
      if remainingCharCount > 0 {
        Text(String(remainingCharCount) + " characters more")
          .fontSemibold(size: 11.5)
          .fgAssetColor(.black)
      }
      Spacer()
      cameraButton
    }
  }
  
  private var cameraButton: some View {
    Button {
      if didReachMaxImageUploads {
        dependencies.appState.showAlert(title: "", message: "You've reached the maximum number of allowed review images.")
        
      } else {
        showPhotoOptionSheet = true
      }
    } label: {
      Image.asset(.ic_camera_fill)
        .icon()
        .padding(10)
        .bgAssetColor(.gray_1)
        .clipInFullCircle()
        .frame(width: 40, height: 40)
    }
    .opacity(didReachMaxImageUploads ? 0.3 : 1)
    .buttonStyle(.plain)

  }
  
  @ViewBuilder private var thumbnails: some View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: maxImageCount)
    LazyVGrid(columns: columns) {
      ForEach(form.images.filter{$0.image != nil}) { item in
        thumbnail(image: item.image!, isUploading: item.isUploading)
          .overlay(alignment: .bottomTrailing) {
            thumbnailCloseButton(thumbnailImageId: item.id)
          }
      }
    }
  }
  
  private func thumbnail(image: Image, isUploading: Bool) -> some View {
    ZStack {
      image
        .thumbnail()
        .opacity(isUploading ? 0.5 : 1)
      if isUploading {
        ProgressView()
      }
    }
  }
  
  private func thumbnailCloseButton(thumbnailImageId: String) -> some View {
    Button {
      form.remove(imageId: thumbnailImageId)
    } label: {
      //  Wrap image in group so we can add padding around the image for bigger tappable area.
      Group {
        Image(systemName: "minus.circle.fill")
          .imageScale(.small)
          .foregroundColor(.red)
          .padding(.trailing, 2)
          .padding(.bottom, 2)
      }
      .padding(.leading, 16)
      .padding(.top, 16)
      .contentShape(Rectangle())
    }
  }
  
  private var photoSourceActionSheet: ActionSheet {
    var buttons: [Alert.Button] = []
    //  Camera
    buttons.append(.default(Text("Take a photo"), action: {
      showCamera = true
    }))
    //  Photos Picker
    buttons.append(.default(Text("Select a photo"), action: {
      showPhotoPicker = true
    }))
    
    buttons.append(.cancel())
    return ActionSheet(title: Text("Select"), buttons: buttons)
  }
  
  @ViewBuilder func buildPost() -> some View {
    switch post {
    case .idle:
      Color.clear
    case .loaded(_):
      Color.clear
        .onAppear {
          isPresentedConfirmation = true
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
extension ProductReviewFormScreen {
  func submit() {
    guard let productId = productEnv.product?.id else { return }
    dependencies.interactors.reviewsInteractor.postReview(productId: productId,
                                                          body: form.body,
                                                          kind: form.sentiment.rawValue,
                                                          questionId: form.questionId,
                                                          imageUrls: form.validImageUrls,
                                                          response: $post)
  }
  
  func saveEdit() {
    guard let reviewId = form.reviewId else { return }
    dependencies.interactors.reviewsInteractor
      .updateReview(id: reviewId,
                    body: form.body,
                    kind: form.sentiment.rawValue,
                    imageUrls: form.validImageUrls,
                    response: $post)
  }
}

//  MARK: - Image Uploading
extension ProductReviewFormScreen {
  /// Display image to UI and upload to server
  func uploadAndDisplayImage() {
    let imageToUpload = inputImage
    guard let image = imageToUpload else {
      print("image not found. Can't proceed to uploading")
      return
    }
    print("proceed to photo upload")
    
    let imageAttributes = form.addImage(uiImage: image)
    uploadImage(imageAttributes)
  }
  
  //  TODO: Move to interactor and use publisher for result
  /// Uploads image to `Cloudinary`
  /// - Parameter image:
  private func uploadImage(_ imageAttributes: ProductReviewForm.ImageAttributes) {
    let config = CLDConfiguration(cloudName: "spinoffdash", secure: true)
    let cloudinary = CLDCloudinary(configuration: config)
    let imageId = imageAttributes.id
    if let data = imageAttributes.uiImage?.jpegData(compressionQuality: 0.7) {
      //  Update uploading state
      form.updateUpload(imageId: imageId, state: true)
      cloudinary.createUploader().upload(data: data,
                                         uploadPreset: "dash_reviews",
                                         params: nil,
                                         progress: nil) { response, error in
        let cloudUrl = response?.resultJson["secure_url"] as? String ?? ""
        syncImageUploadUrl(imageId: imageId, url: cloudUrl)
        print("uploading review image is succesful! -> \(cloudUrl)")
        //  Update uploading state
        form.updateUpload(imageId: imageId, state: false)
      }
    }
  }
  
  private func syncImageUploadUrl(imageId: String, url: String) {
    form.update(imageId: imageId, url: url)
  }
  
  /// Downloads image and sync received image
  /// - Parameter url:
  func downloadImage(url: URL, id: String) {
    service.remoteImagePublisher(url, identifier: id)
      .tryMap { $0.cgImage }
      .catch { _ in
        Just(nil)
      }
      .sink { image in
        if let cgImage = image {
          form.images[form.getImageIndex(id: id)].uiImage = UIImage(cgImage: cgImage)
        }
      }
      .store(in: imageDownloaderCancelBag)
  }
}

struct ProductReviewFormScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ProductReviewFormScreen(form: ProductReviewForm())
    }
  }
}
