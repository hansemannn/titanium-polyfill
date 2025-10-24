/**
 * Axway Titanium
 * Copyright (c) 2018-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

import TitaniumKit


@objc(TiPolyfillActionButton)
public class TiPolyfillActionButton : TiUIView {

  var button = UIButton(type: .custom)
  private var paddingLeft: CGFloat = 10
  private var paddingRight: CGFloat = 10
  let generator = UISelectionFeedbackGenerator()

  public override func initializeState() {
    super.initializeState()

    button.frame = bounds
    
    button.prepareTransitions()
    generator.prepare()
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.buttonTapped))
    button.addGestureRecognizer(tapRecognizer)
    
    addSubview(button)
    updateContentInsets()
  }

  public override func frameSizeChanged(_ frame: CGRect, bounds: CGRect) {
    super.frameSizeChanged(frame, bounds: bounds)
    TiUtils.setView(button, positionRect: bounds)
  }

  public override func contentWidth(forWidth width: CGFloat) -> CGFloat {
    return button.sizeThatFits(CGSize(width: width, height: 0)).width
  }

  public override func contentHeight(forWidth width: CGFloat) -> CGFloat {
    return button.sizeThatFits(CGSize(width: width, height: 0)).height
  }

  func setHorizontalPadding(left: CGFloat, right: CGFloat) {
    paddingLeft = max(0, left)
    paddingRight = max(0, right)
    updateContentInsets()
  }

  func currentPadding() -> (left: CGFloat, right: CGFloat) {
    return (paddingLeft, paddingRight)
  }

  private func updateContentInsets() {
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: paddingLeft, bottom: 0, right: paddingRight)
    button.setNeedsLayout()
    setNeedsLayout()

    if let proxy = proxy as? TiViewProxy {
      proxy.relayout()
    }
  }
  
  @objc func buttonTapped() {
    generator.selectionChanged()
    proxy.fireEvent("click")
  }
}

extension UIButton {
    func prepareTransitions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
      UIView.animate(withDuration: 0.25) {
        button.transform = transform
      }
    }
}
