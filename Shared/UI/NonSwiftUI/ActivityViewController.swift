//
//  ActivityViewController.swift
//  Dash
//
//  Created by Steffi Tan on 2/21/22.
//

import UIKit
import SwiftUI

//  MARK: - UIActivityViewController
struct ActivityViewController: UIViewControllerRepresentable {
  @Binding var activityItems: [Any]
  var excludedActivityTypes: [UIActivity.ActivityType]? = nil
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: activityItems,
                                              applicationActivities: nil)
    
    controller.excludedActivityTypes = excludedActivityTypes
    
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

//  MARK: - View modifier wrapper
extension View {
  func activitySheet(present: Binding<Bool>, items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) -> some View {
    self.modifier(ActivitySheetModifer(showShareSheet: present, shareSheetItems: items, excludedActivityTypes: excludedActivityTypes))
  }
}

//  MARK: - ViewModifier
struct ActivitySheetModifer: ViewModifier {
  @Binding var showShareSheet: Bool
  @State var shareSheetItems: [Any] = []
  var excludedActivityTypes: [UIActivity.ActivityType]? = nil
  
  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $showShareSheet, onDismiss: {
        showShareSheet = false
      }, content: {
        ActivityViewController(activityItems: self.$shareSheetItems, excludedActivityTypes: excludedActivityTypes)
      })
  }
}
