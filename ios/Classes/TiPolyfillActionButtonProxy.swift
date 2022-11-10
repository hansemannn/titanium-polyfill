/**
 * Axway Titanium
 * Copyright (c) 2018-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

import TitaniumKit

@objc(TiPolyfillActionButtonProxy)
public class TiPolyfillActionButtonProxy : TiViewProxy {
  
  func buttonInstance() -> UIButton {
    return (view as! TiPolyfillActionButton).button
  }

  @objc(setTitle:)
  func setTitle(value: Any) {
    let title = TiUtils.stringValue(value) ?? ""
    buttonInstance().setTitle(title, for: .normal)
  }
  
  @objc(setButtonBackgroundColor:)
  func setButtonBackgroundColor(value: Any) {
    let buttonBackgroundColor = TiUtils.colorValue(value)
    buttonInstance().backgroundColor = buttonBackgroundColor?.color
  }
  
  @objc(setButtonTextColor:)
  func setButtonTextColor(value: Any) {
    let buttonTextColor = TiUtils.colorValue(value)
    buttonInstance().setTitleColor(buttonTextColor?.color, for: .normal)
  }

  @objc(setFont:)
  func setFont(value: Any) {
    let font = TiUtils.fontValue(value)
    buttonInstance().titleLabel?.font = font?.font()
  }
  
  @objc(setBorderRadius:)
  func setBorderRadius(value: Any) {
    let borderRadius = TiUtils.floatValue(value, def: 15.0)
    buttonInstance().layer.cornerRadius = borderRadius
  }
  
  @objc(setBorderColor:)
  func setBorderColor(value: Any) {
    let borderColor = TiUtils.colorValue(value)
    buttonInstance().layer.borderColor = borderColor?.color.cgColor
  }
  
  @objc(setBorderWidth:)
  func setBorderWidth(value: Any) {
    let borderWidth = TiUtils.floatValue(value, def: 0.0)
    buttonInstance().layer.borderWidth = borderWidth
  }
  
  @objc(setMenu:)
  @available(iOS 14.0, *)
  func setMenu(value: Any) {
    let menu = menuFromJavaScriptArray(value as? [[String: String]] ?? [], proxy: self)

    buttonInstance().menu = menu
    buttonInstance().showsMenuAsPrimaryAction = true
  }
  
  @available(iOS 13.0, *)
  private func menuFromJavaScriptArray(_ actions: [[String: Any]], proxy: TiProxy) -> UIMenu {
    let strongSelf = self

    let children = actions.enumerated().map { (index, obj) in
      let title = obj["title"] as! String
      let image = TiUtils.toImage(obj["image"], proxy: self)
      let destructive = TiUtils.boolValue("destructive", properties: obj, def: false)
      
      let action = UIAction(title: title, image: image) { nativeAction in
        NSLog("[WARN] INDEX = \(index)")
        strongSelf.fireEvent("menuclick", with: ["index", index])
      }
      
      if destructive {
        action.attributes = [.destructive]
      }
      
      return action
    } as [UIAction]
    
    return UIMenu(children: children)
  }
}
