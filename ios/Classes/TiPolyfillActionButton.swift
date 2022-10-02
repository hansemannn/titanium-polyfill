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
  let generator = UISelectionFeedbackGenerator()

  public override func initializeState() {
    super.initializeState()

    button.frame = bounds
    
    button.prepareTransitions()
    generator.prepare()
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.buttonTapped))
    button.addGestureRecognizer(tapRecognizer)
    
    addSubview(button)
  }

  public override func frameSizeChanged(_ frame: CGRect, bounds: CGRect) {
    TiUtils.setView(button, positionRect: bounds)
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
