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
}
