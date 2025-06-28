//
//  ImageCrop+Models.swift
//  Dash
//
//  Created by Steffi Tan on 3/23/22.
//

import SwiftUI

extension ImageCrop {
  class ViewModel: ObservableObject {
    
    @Published var image = Image(systemName: "star.fill")
    @Published var originalImage: UIImage?
    @Published var scale: CGFloat = 1.0
    @Published var xWidth: CGFloat = 0.0
    @Published var yHeight: CGFloat = 0.0
    var position: CGSize {
      get {
        return CGSize(width: xWidth, height: yHeight)
      }
    }
    //Localized strings
    let moveAndScale = NSLocalizedString("Move and Scale", comment: "indicate that the user may use gestures to move and or scale the image")
    let selectPhoto = NSLocalizedString("Select a photo by tapping the icon below", comment: "indicate that the user may select a photo by tapping on the green icon")
    let cancelSheet = NSLocalizedString("Cancel", comment: "indicate that the user cancel the action, closing the sheet")
    let usePhoto = NSLocalizedString("Save", comment: "indicate that the user may use the photo as currently displayed")
    
    func updateImageAttributes(_ imageAttributes: ImageCrop.ImageAttributes) {
      imageAttributes.image = image
      imageAttributes.originalImage = originalImage
      imageAttributes.scale = scale
      imageAttributes.xWidth = position.width
      imageAttributes.yHeight = position.height
    }
    
    func loadImageAttributes(_ imageAttributes: ImageCrop.ImageAttributes) {
      self.image = imageAttributes.image
      self.originalImage = imageAttributes.originalImage
      self.scale = imageAttributes.scale
      self.xWidth = imageAttributes.position.width
      self.yHeight = imageAttributes.position.height
    }
  }
}

//  MARK: - ImageAttributes
extension ImageCrop {
  class ImageAttributes: ObservableObject {
    
    ///Cropped and / or scaled image take from originalImage
    @Published public var image: Image
    
    ///The original image selected before cropping or scaling
    @Published public var originalImage: UIImage?
    
    ///The cropped image as a UIImage for easier persistence in applcations.
    @Published public var croppedImage: UIImage?
    
    ///The magnification of the cropped image
    @Published public var scale: CGFloat
    
    ///Used to determine the horizontal position or x-offset of the original image in the "viewfinder"
    @Published public var xWidth: CGFloat
    
    ///Used to determine the vertical position or y-offset of the original image in the "viewfinder"
    @Published public var yHeight: CGFloat
    
    ///A CGSize computed from xWidth and yHeight.
    public var position: CGSize {
      get {
        return CGSize(width: xWidth, height: yHeight)
      }
    }
    
    ///Used to create an ImageAssets object from properties which are for example stored in CoreData or @AppStorage.
    public init(image: Image, originalImage: UIImage?, croppedImage: UIImage?, scale: CGFloat, xWidth: CGFloat, yHeight: CGFloat) {
      self.image = image
      self.originalImage = originalImage
      self.croppedImage = croppedImage
      self.scale = scale
      self.xWidth = xWidth
      self.yHeight = yHeight
    }
    
    ///Allows ImageAttributes to be configured with an SF Symbol name string.
    ///For example: `ImageAttributes("person.crop.circle")`
    public init(withSFSymbol name: String) {
      self.image = Image(systemName: name)
      self.scale = 1.0
      self.xWidth = 1.0
      self.yHeight = 1.0
    }
    
    ///Allows ImageAttributes to be configured with an image from the Asset Catalogue.
    public init(withImage name: String) {
      self.image = Image(name)
      self.scale = 15.0
      self.xWidth = 1.0
      self.yHeight = 1.0
    }
    
    init() {
      self.image = Image(uiImage: UIImage())
      self.scale = 1.0
      self.xWidth = 1.0
      self.yHeight = 1.0
    }
    
    func resetScaleAndPoints() {
      self.scale = 1.0
      self.xWidth = 1.0
      self.yHeight = 1.0
    }
  }

}
