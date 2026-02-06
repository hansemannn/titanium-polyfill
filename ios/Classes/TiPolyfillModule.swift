//
//  TiPolyfillModule.swift
//  titanium-polyfill
//
//  Created by Hans Knöchel
//  Copyright (c) 2022 Hans Knöchel
//

import UIKit
import AVKit
import TitaniumKit
import Network
import PDFKit

@objc(TiPolyfillModule)
class TiPolyfillModule: TiModule {
  
  private var tabGroupHeight = 0.0
  private var lastBottomSpacing: CGFloat = -1
  private var lastKeyboardVisible = false
    
  private var pathMonitor: NWPathMonitor? = nil
  
  private var currentNetworkStatus: NWPath.Status? = nil

  func moduleGUID() -> String {
    return "79b0059b-4142-47d3-8bac-586c5a859586"
  }
  
  override func moduleId() -> String! {
    return "ti.polyfill"
  }
  
  @objc(isDarkImage:)
  func isDarkImage(args: [Any]) -> Bool {
    guard let imageProxy = args.first else { return false }
    guard let image = TiUtils.image(imageProxy, proxy: self) else { return false }
    
    return image.ti_isDark
  }
  
  @objc(formattedDateRange:)
  func formattedDateRange(args: [Any]) -> String? {
    guard let params = args.first as? [String: String],
          let startDate = params["startDate"],
          let endDate = params["endDate"] else {
      fatalError("Invalid parameters")
    }
    
    let formatter = DateIntervalFormatter()
    formatter.locale = Locale.current
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    
    let dateFormatter = DateFormatter()
    guard let startDateNative = dateFormatter.date(from: startDate),
          let endDateNative = dateFormatter.date(from: endDate) else {
      return nil
    }
    
    return formatter.string(from: startDateNative, to: endDateNative)
  }
  
  @objc(openFullscreenVideoPlayer:)
  func openFullscreenVideoPlayer(args: [Any]) {
    guard let params = args.first as? [String: Any] else { return }
    guard let url = params["url"] as? String else { return }
    
    let player = AVPlayer(url: URL(string: url)!)
    let vc = AVPlayerViewController()
    vc.player = player
    vc.modalPresentationStyle = .overFullScreen;
    
    TiThreadPerformOnMainThread({
      TiApp.controller().topPresentedController().present(vc, animated: true) {
        let selectorName: String = {
          if #available(iOS 11.3, *) {
            return "_transitionToFullScreenAnimated:interactive:completionHandler:"
          } else {
            return "_transitionToFullScreenAnimated:completionHandler:"
          }
        }()
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)
        
        if vc.responds(to: selectorToForceFullScreenMode) {
          vc.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
        vc.player?.play()
      }
    }, false)
  }
  
  @objc(isAppInstalled:)
  func isAppInstalled(args: [Any]?) -> Bool {
    guard let packageId = args?.first as? String, let url = URL(string: "\(packageId)://") else {
      return false
    }
    
    return UIApplication.shared.canOpenURL(url)
  }
  
  @objc(relativeDateString:)
  func relativeDateString(args: [Any]) -> String {
    guard let date = args.first as? Date else {
      fatalError("Missing date")
    }
    
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    
    return formatter.localizedString(for: date, relativeTo: Date())
  }

  @objc(startListeningForKeyboardUpdates:)
  func startListeningForKeyboardUpdates(params: [Any]) {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardFrameChanged),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillHideFallback),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  @objc(stopListeningForKeyboardUpdates:)
  func stopListeningForKeyboardUpdates(params: [Any]) {
    NotificationCenter.default.removeObserver(self,
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil)

    NotificationCenter.default.removeObserver(self,
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  @objc private func keyboardFrameChanged(_ notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    guard let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

    let endFrameScreen = keyboardFrameValue.cgRectValue
    let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0) * 1000

    // Keyboard's animation curve
    let keyboardCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0

    // Ensure window exists
    let window: UIWindow? =
        TiApp.controller().view.window ??
        UIApplication.shared.windows.first { $0.isKeyWindow }

    guard let window else { return }

    // Convert keyboard frame into window coordinate space
    let endFrame = window.convert(endFrameScreen, from: nil)
    let windowBounds = window.bounds

    // Keyboard can be docked, floating or split, compute visible state by intersection with the window.
    let intersection = windowBounds.intersection(endFrame)
    let keyboardVisible = !intersection.isNull && intersection.height > 0 && intersection.width > 0

    // Floating keyboards should not add bottom spacing; detect by width vs. window.
    let isFloating = endFrame.width < windowBounds.width * 0.8
    let bottomSpacing = isFloating ? 0 : max(0, intersection.height)

    // Ignore duplicate events triggered for tiny tolerances.
    if abs(bottomSpacing - lastBottomSpacing) < 0.5 && keyboardVisible == lastKeyboardVisible {
      return
    }

    let transitionType = keyboardVisible ? "show" : "hide"

    lastBottomSpacing = bottomSpacing
    lastKeyboardVisible = keyboardVisible

    fireEvent("keyboardChanged", with: [
      "transitionType": transitionType,
      "bottomSpacing": bottomSpacing,
      "isFloating": isFloating,
      "duration": duration,
      "curve": keyboardCurve
    ])
  }

  @objc private func keyboardWillHideFallback(_ notification: Notification) {
    if lastBottomSpacing == 0 { return }

    lastBottomSpacing = 0
    lastKeyboardVisible = false

    fireEvent("keyboardChanged", with: [
      "transitionType": "hide",
      "bottomSpacing": 0,
      "isFloating": false,
      "duration": 250,
      "curve": 0
    ])
  }
  
  @objc(getNetworkStatus:)
  func getNetworkStatus(unused: Any?) -> String? {
    guard let pathMonitor else {
      NSLog("[WARN]", "Called \"getNetworkStatus()\" without having an active instance: Make sure to call \"startListeningForNetworkUpdates\" before! Skipping call …")
      return nil
    }
    
    return self.formatNetworkStatus(pathMonitor.currentPath)
  }
  
  @objc(startListeningForNetworkUpdates:)
  func startListeningForNetworkUpdates(unused: Any?) {
    if pathMonitor != nil {
      NSLog("[WARN]", "Called \"startListeningForNetworkUpdates\" more than once: Make sure to call \"stopListeningForNetworkUpdates\" before! Skipping call …")
      return
    }

    self.pathMonitor = NWPathMonitor()
    
    guard let pathMonitor else {
      return
    }

    pathMonitor.pathUpdateHandler = { path in
      self.fireNetworkUpdate(path)
    }
    
    pathMonitor.start(queue: .global(qos: .background))
    fireNetworkUpdate(pathMonitor.currentPath)
  }
  
  @objc(stopListeningForNetworkUpdates:)
  func stopListeningForNetworkUpdates(unused: Any?) {
    guard let pathMonitor else {
      NSLog("[WARN]", "Called \"stopListeningForNetworkUpdates\" without having an active instance: Make sure to call \"startListeningForNetworkUpdates\" before! Skipping call …")
      return
    }
    
    pathMonitor.cancel()
    
    self.pathMonitor = nil
    self.currentNetworkStatus = nil
  }
  
  @objc(convertTiffToPDF:)
  func convertTiffToPDF(params: [Any]) -> String? {
    guard let urlString = params.first as? String, let filename = params[1] as? String else {
      fatalError("Missing required .tiff URL")
    }
    
    guard let url = TiUtils.toURL(urlString, proxy: self),
          let pdfURL = convertMultiPageTIFFToPDF(url: url, filename: filename) else { return nil }
    
    return pdfURL.absoluteString
  }
  
  private func formatNetworkStatus(_ path: NWPath) -> String {
    if path.status == .satisfied {
      if path.usesInterfaceType(.wifi) {
        return "wifi"
      } else if path.usesInterfaceType(.cellular) {
        return "cellular"
      } else if path.usesInterfaceType(.wiredEthernet) {
        return "wiredEthernet"
      } else if path.usesInterfaceType(.loopback) {
        return "loopback"
      } else if path.usesInterfaceType(.other) {
        return "other"
      }
    }
    
    return "notConnected"
  }
  
  private func fireNetworkUpdate(_ currentPath: NWPath) {
    let status = self.formatNetworkStatus(currentPath)

    TiThreadPerformOnMainThread({
      if self.currentNetworkStatus != currentPath.status {
        self.currentNetworkStatus = currentPath.status
        self.fireEvent("networkChange", with: ["status": status])
      }
    }, false)
  }
}

extension CGImage {
    var ti_isDark: Bool {
        get {
            guard let imageData = self.dataProvider?.data else { return false }
            guard let ptr = CFDataGetBytePtr(imageData) else { return false }
            let length = CFDataGetLength(imageData)
            let threshold = Int(Double(self.width * self.height) * 0.45)
            var darkPixels = 0

            for i in stride(from: 0, to: length, by: 4) {
                let r = ptr[i]
                let g = ptr[i + 1]
                let b = ptr[i + 2]
                let luminance = (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                if luminance < 150 {
                    darkPixels += 1
                    if darkPixels > threshold {
                        return true
                    }
                }
            }
            return false
        }
    }
}

extension UIImage {
    var ti_isDark: Bool {
        get {
            return self.cgImage?.ti_isDark ?? false
        }
    }
}
