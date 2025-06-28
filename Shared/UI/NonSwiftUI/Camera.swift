//
//  Camera.swift
//  Dash
//
//  Created by Steffi Tan on 3/23/22.
//

import UIKit
import SwiftUI

struct Camera: UIViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentationMode
  var sourceType: UIImagePickerController.SourceType = .camera
  @Binding var selectedImage: UIImage?
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = false
    imagePicker.sourceType = sourceType
    imagePicker.delegate = context.coordinator
    return imagePicker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parent: Camera
    
    init(_ parent: Camera) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      
      if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        parent.selectedImage = image
      }
      //  Auto dismiss
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}
