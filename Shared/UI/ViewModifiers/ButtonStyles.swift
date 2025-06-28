//
//  ButtonStyles.swift
//  Dash
//
//  Created by Steffi Tan on 2/13/22.
//

import SwiftUI

//  MARK: - Button Style
enum AppButtonStyle {
  case primary
  case primaryFullWidth
  case primaryText
  case flatLink
  case grayscalePrimary
}

//  MARK: - View extension
extension View {
  // MARK: - Button
  @ViewBuilder
  func appButtonStyle(_ style: AppButtonStyle) -> some View {
    switch style {
    case .primary:
      buttonStyle(AppPrimaryButtonStyle())
    case .primaryFullWidth:
      buttonStyle(AppPrimaryWideButtonStyle())
    case .primaryText:
      buttonStyle(AppPrimaryTextButtonStyle())
    case .flatLink:
      buttonStyle(FlatLinkButtonStyle())
    case .grayscalePrimary:
      buttonStyle(GrayscalePrimaryButtonStyle())
    default:
      buttonStyle(.plain)
    }
  }
}

//  MARK: - Button styles
/// Plain and removes opacity animation on  tap.
struct FlatLinkButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
  }
}

/// Solid purple
struct AppPrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, 44)
      .padding(.vertical, 14)
      .bgAssetColor(.purple)
      .fontBold(size: 16)
      .fgAssetColor(.white)
      .cornerRadius(8)
  }
}

/// Solid purple with infinite max width
struct AppPrimaryWideButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .padding(.vertical, 14)
      .bgAssetColor(.purple)
      .fontBold(size: 16)
      .fgAssetColor(.white)
      .cornerRadius(8)
  }
}

/// Solid black/gray
struct GrayscalePrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, 44)
      .padding(.vertical, 14)
      .background(Color.black.opacity(0.1))
      .fontBold(size: 16)
      .foregroundColor(Color.black.opacity(0.25))
      .cornerRadius(8)
  }
}


/// Solid black/gray
struct AppPrimaryTextButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .fontBold(size: 16)
      .fgAssetColor(.purple)
  }
}
