//
//  ProfileImage.swift
//  Dash
//
//  Created by Steffi Tan on 3/28/22.
//

import SwiftUI
import Cloudinary
import URLImage
import Combine

struct ProfileImage: View {
  @Environment(\.urlImageService) var imageService: URLImageService
  /// Displayed image on the UI.
  @State private var image: Image = Image(uiImage: UIImage())
  //  - Image
  /// Selected image from either `Camera` or `ImagePicker`
  @State private var inputImage: UIImage?
  @State var isUploadingImage = false
  @StateObject private var imageCrop = ImageCrop.ImageAttributes()
  /// Actionsheet to choose photo source - Camera or Photo Picker
  @State private var showPhotoOptionSheet = false
  /// Present `Camera` in a fullscreen sheet
  @State private var showCamera = false
  /// Present `ImagePicker` in a sheet
  @State private var showPhotoPicker = false
  /// Present `ImageCrop` in full screen sheet for cropping `inputImage`
  @State private var showImageCropper = false
  private let cancelBag = CancelBag()
  
  @Binding var imageUrl: String
  let size: CGSize
  var actionIconConfiguration: ProfileImage.IconSize = .normal
  
  var body: some View {
    VStack {
      ZStack(alignment: .center) {
        image
          .scaleFill()
          .opacity(isUploadingImage ? 0.5 : 1)
          .background(Color(.secondarySystemFill))
          .clipInFullCircle()
          .overlay(alignment: .center) {
            if imageUrl.isEmpty && !isUploadingImage && inputImage == nil {
              Image(systemName: "person.fill")
                .icon()
                .frame(width: 50, height: 50)
                .foregroundColor(Color.hex("C1C1C1"))
            }
          }
          .overlay(alignment: .bottomTrailing) {
            cameraIcon
          }
        if isUploadingImage {
          ProgressView()
        }
      }
      .frame(width: size.width, height: size.height)
    }
   
    .onTapGesture {
      showPhotoOptionSheet = true
    }
    //  Photo source
    .actionSheet(isPresented: $showPhotoOptionSheet, content: {
      photoSourceActionSheet
    })
    // Photo Picker
    .sheet(isPresented: $showPhotoPicker) {
      ImagePicker(image: $inputImage)
    }
    //  ImageCrop
    .fullScreenCover(isPresented: $showImageCropper, content: {
      ImageCrop(viewModel: ImageCrop.ViewModel(),
                inputImage: $inputImage,
                imageAttributes: imageCrop)
    })
    //  Camera
    .fullScreenCover(isPresented: $showCamera) {
      Camera(selectedImage: $inputImage)
        .ignoresSafeArea()
    }
    
    // Events
    .onChange(of: inputImage) { newValue in
      //showCamera = false
      //  Make sure that cropping always start with the defautl scale and points.
      imageCrop.resetScaleAndPoints()
      showImageCropper = true
    }
    .onChange(of: imageCrop.image) { newValue in
      uploadAndDisplayImage()
    }
    .onAppear {
      print("profile image appear")
      downloadProfileImage()
    }
  }
}

//  MARK: Views
extension ProfileImage {
  enum IconSize {
    case normal
    case large
    
    var size: CGSize {
      switch self {
      case .normal:
        return .init(width: 30, height: 30)
      case .large:
        return .init(width: 40, height: 40)
      }
    }
    
    var padding: CGFloat {
      switch self {
      case .normal:
        return 6
      case .large:
        return 10
      }
    }
  }
  
  private var cameraIcon: some View {
    Image.asset(.ic_camera_fill)
      .icon()
      .padding(actionIconConfiguration.padding)
      .background(Color.white)
      .clipInFullCircle()
      .frame(width: actionIconConfiguration.size.width, height: actionIconConfiguration.size.height)
      .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 5)

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
}

// MARK: - Functions
extension ProfileImage {
  /// Display image to UI and upload to server
  func uploadAndDisplayImage() {
    //  Use image, if nil fallback to original (original is a mirror of inputImage).
    let imageToUpload = imageCrop.croppedImage ?? imageCrop.originalImage
    guard let image = imageToUpload else {
      print("image not found. Can't proceed to uploading")
      return
    }
    print("proceed to photo upload")
    uploadImage(image)
    self.image = Image(uiImage: image)
  }
  
  //  TODO: Move to interactor and use publisher for result
  /// Uploads image to `Cloudinary`
  /// - Parameter image:
  private func uploadImage(_ image: UIImage) {
    let config = CLDConfiguration(cloudName: "spinoffdash", secure: true)
    let cloudinary = CLDCloudinary(configuration: config)
    if let data = image.jpegData(compressionQuality: 0.7) {
      isUploadingImage = true
      cloudinary.createUploader().upload(data: data, uploadPreset: "ml_default", params: nil, progress: nil) { response, error in
        let cloudUrl = response?.resultJson["secure_url"] as? String ?? ""
        print("uploading profile image is succesful! -> \(cloudUrl)")
        imageUrl = cloudUrl
        isUploadingImage = false
      }
    }
  }
  
  private func downloadProfileImage() {
    guard !imageUrl.isEmpty, let imageURL = URL(string: imageUrl) else { return }
    imageService.remoteImagePublisher(imageURL, identifier: nil)
      .tryMap { $0.cgImage }
      .catch { _ in
        Just(nil)
      }
      .sink { img in
        if let cgImage = img {
          self.image = Image(uiImage: UIImage(cgImage: cgImage))
        }
      }
      .store(in: cancelBag)
  }
}

struct ProfileImage_Previews: PreviewProvider {
  static var previews: some View {
    ProfileImage(imageUrl: .constant(""), size: .init(width: 100, height: 100))
  }
}
