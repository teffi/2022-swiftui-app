//
//  ImageCrop.swift
//  Dash
//
//  Created by Steffi Tan on 3/23/22.
//  Reference: https://github.com/Rillieux/PhotoSelectAndCrop
//

import SwiftUI

struct ImageCrop: View {
  
  @Environment(\.presentationMode) var presentationMode

  @StateObject var viewModel: ImageCrop.ViewModel
  
  @ObservedObject public var imageAttributes: ImageCrop.ImageAttributes
  
  ///The input image is received from the ImagePicker.
  ///We will need to calculate and refer to its aspectr ratio
  ///in the functions found in the extensions file.
  @Binding var inputImage: UIImage?
  
  init(viewModel: ViewModel = .init(),
       inputImage: Binding<UIImage?>,
       imageAttributes: ImageAttributes) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _inputImage = inputImage
    self._imageAttributes = ObservedObject(initialValue: imageAttributes)
  }
  
  @State var originalZoom: CGFloat?
  ///A `CGFloat` representing the ascpect ratio of the selected `UIImage`.
  ///
  ///This variable is necessary in order to determine how to reposition
  ///the `displayImage` as the [repositionImage](x-source-tag://repositionImage) function must know if the displayImage is "letterboxed" horizontally or vertically in order reposition correctly.
  @State var inputImageAspectRatio: CGFloat = 0.0
  
  ///The displayImage is what wee see on this view. When added from the
  ///ImapgePicker, it will be sized to fit the screen,
  ///meaning either its width will match the width of the device's screen,
  ///or its height will match the height of the device screen.
  ///This is not suitable for landscape mode or for iPads.
  @State var displayedImage: UIImage?
  @State var displayW: CGFloat = 0.0
  @State var displayH: CGFloat = 0.0
  
  //Zoom and Drag ...
  
  @State var currentAmount: CGFloat = 0
  @State var zoomAmount: CGFloat = 1.0
  @State var currentPosition: CGSize = .zero
  @State var newPosition: CGSize = .zero
  @State var horizontalOffset: CGFloat = 0.0
  @State var verticalOffset: CGFloat = 0.0
  
  //Local variables
  
  ///A CGFloat used to "pad" the circle set into the view.
  let inset: CGFloat = 15
  
  ///find the length of the side of a square which will fit inside
  ///the Circle() shape of our mask to be sure all SF Symbol images fit inside.
  ///For the sake of sanity, just multiply the inset by 2.
  let defaultImageSide = (UIScreen.main.bounds.width - (30)) * CGFloat(2).squareRoot() / 2
  
  var body: some View {
    
    ZStack {
      ZStack {
        Color.black.opacity(0.6)
        if viewModel.originalImage != nil {
          Image(uiImage: viewModel.originalImage!)
            .resizable()
            .scaleEffect(zoomAmount + currentAmount)
            .scaledToFill()
            .aspectRatio(contentMode: .fit)
            .offset(x: self.currentPosition.width, y: self.currentPosition.height)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .clipped()
        } else {
          viewModel.image
            .resizable()
            .scaledToFill()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(.systemGray2))
          ///Padding is added if the default image is from the asset catalogue.
          ///See line 45 in ImageAttributes.swift.
            .padding(inset * 2)
        }
      }
      
      Rectangle()
        .fill(Color.black).opacity(0.55)
        .mask(HoleShapeMask().fill(style: FillStyle(eoFill: true)))
      
      VStack {
        Spacer()
        HStack {
          cancelButton
          Spacer()
          saveButton
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
        .foregroundColor(.white)
      }
    }
    .edgesIgnoringSafeArea(.all)
    .onAppear(perform: {
      viewModel.loadImageAttributes(imageAttributes)
      loadImage()
    })
    
    //MARK: - Gestures
    
    .gesture(
      MagnificationGesture()
        .onChanged { amount in
          self.currentAmount = amount - 1
        }
        .onEnded { amount in
          self.zoomAmount += self.currentAmount
          if zoomAmount > 4.0 {
            withAnimation {
              zoomAmount = 4.0
            }
          }
          self.currentAmount = 0
          withAnimation {
            repositionImage()
          }
        }
    )
    .simultaneousGesture(
      DragGesture()
        .onChanged { value in
          self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
        }
        .onEnded { value in
          self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
          self.newPosition = self.currentPosition
          withAnimation {
            repositionImage()
          }
        }
    )
    .simultaneousGesture(
      TapGesture(count: 2)
        .onEnded(  { resetImageOriginAndScale() } )
    )
    .onAppear(perform: setCurrentImage )
  }
  
  ///Sets the mask to darken the background of the displayImage.
  ///
  /// - Parameter rect: a CGRect filling the device screen.
  ///
  ///Code for mask obtained from [StackOVerflow](https://stackoverflow.com/questions/59656117/swiftui-add-inverted-mask)
  func HoleShapeMask() -> Path {
    let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    let insetRect = CGRect(x: inset, y: inset, width: UIScreen.main.bounds.width - ( inset * 2 ), height: UIScreen.main.bounds.height - ( inset * 2 ))
    var shape = Rectangle().path(in: rect)
    shape.addPath(Circle().path(in: insetRect))
    return shape
  }
  
  //MARK: - Buttons, Labels
  
  private var cancelButton: some View {
    Button {
      presentationMode.wrappedValue.dismiss()
    } label: {
      Text(viewModel.cancelSheet).fontSemibold(size: 18)
    }
  }
  
  private var saveButton: some View {
    Button {
      composeImageAttributes()
      presentationMode.wrappedValue.dismiss()
    } label: {
      Text(viewModel.usePhoto).fontSemibold(size: 18)
    }
    .opacity((viewModel.originalImage != nil) ? 1.0 : 0.2)
    .disabled((viewModel.originalImage != nil) ? false: true)
  }
}

//  MARK: - Preview
struct ImageCrop_Previews: PreviewProvider {
  static var previews: some View {
    ImageCrop(viewModel: ImageCrop.ViewModel(),
              inputImage: .constant(UIImage(named: "test_selfie_portrait")),
              imageAttributes: ImageCrop.ImageAttributes(withImage: ""))
  }
}

//  MARK: - Extension

extension ImageCrop {
  /// Loads an image selected by the user from an ImagePicker with access to the user's photo library.
  ///
  /// First, we want to measure the image top imput and determine its aspect ratio.
  func loadImage() {
    guard let inputImage = inputImage else { return }
    let w = inputImage.size.width
    let h = inputImage.size.height
    viewModel.originalImage = inputImage
    inputImageAspectRatio = w / h
    resetImageOriginAndScale()
  }
  
  
  ///Loads the current image when the view appears.
  func setCurrentImage() {
    guard let currentImage = viewModel.originalImage else { return }
    let w = currentImage.size.width
    let h = currentImage.size.height
    inputImage = currentImage
    inputImageAspectRatio = w / h
    currentPosition = imageAttributes.position
    newPosition = imageAttributes.position
    zoomAmount = imageAttributes.scale
    viewModel.originalImage = currentImage
    repositionImage()
  }
  
  ///A CGFloat used to determine the aspect ratio of the device screen
  ///in its current orientation.
  ///
  ///The displayImage will size to fit the screen.
  ///But we need to know the width and height of
  ///the screen to size it appropriately.
  ///Double-tapping the image will also set it
  ///as it was sized originally upon loading.
  private func getAspect() -> CGFloat {
    let screenAspectRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
    return screenAspectRatio
  }
  
  
  ///Positions the image selected to fit the screen.
  func resetImageOriginAndScale() {
    print("reposition")
    let screenAspect: CGFloat = getAspect()
    
    withAnimation(.easeInOut){
      if inputImageAspectRatio >= screenAspect {
        displayW = UIScreen.main.bounds.width
        displayH = displayW / inputImageAspectRatio
      } else {
        displayH = UIScreen.main.bounds.height
        displayW = displayH * inputImageAspectRatio
      }
      currentAmount = 0
      zoomAmount = 1
      currentPosition = .zero
      newPosition = .zero
    }
  }
  
  /// - Tag: repositionImage
  func repositionImage() {
    
    ///Setting the display width and height so the imputImage fits the screen
    ///orientation.
    let screenAspect: CGFloat = getAspect()
    let diameter = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    
    if screenAspect <= 1.0 {
      if inputImageAspectRatio > screenAspect {
        displayW = diameter * zoomAmount
        displayH = displayW / inputImageAspectRatio
      } else {
        displayH = UIScreen.main.bounds.height * zoomAmount
        displayW = displayH * inputImageAspectRatio
      }
    } else {
      if inputImageAspectRatio < screenAspect {
        displayH = diameter * zoomAmount
        displayW = displayH * inputImageAspectRatio
      } else {
        displayW = UIScreen.main.bounds.width * zoomAmount
        displayH = displayW / inputImageAspectRatio
      }
    }
    
    horizontalOffset = (displayW - diameter ) / 2
    verticalOffset = ( displayH - diameter) / 2
    
    ///Keep the user from zooming too far in. Adjust as required in your individual project.
    if zoomAmount > 4.0 {
      zoomAmount = 4.0
    }
    
    ///If the view which presents the ImageMoveAndScaleSheet is embeded in a NavigationView then the vertical offset is off.
    ///A value of 0.0 appears to work when the view is not embeded in a NAvigationView().
    
    ///When it is embedded in a NvaigationView, a value of 4.0 seems to keep images displaying as expected.
    ///This appears to be a SwiftUI bug. So, we "pad" the function with this "adjust". YMMV.
    
    let adjust: CGFloat = 0.0
    
    ///The following if statements keep the image filling the circle cutout in at least one dimension.
    if displayH >= diameter {
      if newPosition.height > verticalOffset {
        print("1. newPosition.height > verticalOffset")
        newPosition = CGSize(width: newPosition.width, height: verticalOffset - adjust + inset)
        currentPosition = CGSize(width: newPosition.width, height: verticalOffset - adjust + inset)
      }
      
      if newPosition.height < ( verticalOffset * -1) {
        print("2. newPosition.height < ( verticalOffset * -1)")
        newPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - adjust - inset)
        currentPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - adjust - inset)
      }
      
    } else {
      print("else: H")
      newPosition = CGSize(width: newPosition.width, height: 0)
      currentPosition = CGSize(width: newPosition.width, height: 0)
    }
    
    if displayW >= diameter {
      if newPosition.width > horizontalOffset {
        print("3. newPosition.width > horizontalOffset")
        newPosition = CGSize(width: horizontalOffset + inset, height: newPosition.height)
        currentPosition = CGSize(width: horizontalOffset + inset, height: currentPosition.height)
      }
      
      if newPosition.width < ( horizontalOffset * -1) {
        print("4. newPosition.width < ( horizontalOffset * -1)")
        newPosition = CGSize(width: ( horizontalOffset * -1) - inset, height: newPosition.height)
        currentPosition = CGSize(width: ( horizontalOffset * -1) - inset, height: currentPosition.height)
        
      }
      
    } else {
      print("else: W")
      newPosition = CGSize(width: 0, height: newPosition.height)
      currentPosition = CGSize(width: 0, height: newPosition.height)
    }
    
    ///This statement is needed in case of a screenshot.
    ///That is, in case the user chooses a photo that is the exact size of the device screen.
    ///Without this function, such an image can be shrunk to less than the
    ///size of the cutrout circle and even go negative (inversed).
    ///If "processImage()" is run in this state, there is a fatal error. of a nil UIImage.
    ///
    if displayW < diameter - inset && displayH < diameter - inset {
      resetImageOriginAndScale()
    }
  }
  
  /// - Tag: processImage
  ///A function to save a process the image.
  ///
  /// - Note: But if the user saves the image in one mode and them opens it in another, the
  ///scale and size will be slightly off.
  ///
  func composeImageAttributes() {
    
    let scale = (inputImage?.size.width)! / displayW
    let originAdjustment = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    let diameter = ( originAdjustment - inset * 2 ) * scale
    
    let xPos = ( ( ( displayW - originAdjustment ) / 2 ) + inset + ( currentPosition.width * -1 ) ) * scale
    let yPos = ( ( ( displayH - originAdjustment ) / 2 ) + inset + ( currentPosition.height * -1 ) ) * scale
    
    let tempUIImage: UIImage = croppedImage(from: inputImage!, croppedTo: CGRect(x: xPos, y: yPos, width: diameter, height: diameter))
    
    imageAttributes.image = Image(uiImage: tempUIImage)
    imageAttributes.originalImage = inputImage
    imageAttributes.croppedImage = tempUIImage
    imageAttributes.scale = zoomAmount
    imageAttributes.xWidth = currentPosition.width
    imageAttributes.yHeight = currentPosition.height
  }
  
  
  /// Crops a UIImage
  /// - Parameters:
  ///   - image: the original image before processing.
  ///   - rect: the CGRect to which the image will be cropped.
  /// - Returns: UIImage.
  func croppedImage(from image: UIImage, croppedTo rect: CGRect) -> UIImage {
    
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: image.size.width, height: image.size.height)
    
    context?.clip(to: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
    
    image.draw(in: drawRect)
    
    let subImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    return subImage!
  }
}
