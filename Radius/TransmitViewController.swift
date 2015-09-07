//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit
import AudioBarcodeKit


class TransmitViewController: UIViewController {
  
  static var tokens = [0x8001, 0x1234, 0x4444, 0x2828].map(Token.init)
  var tokenButtons = [UIButton]() // must be same order as the tokens
  let transmitter = Transmitter(token: tokens[0])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    
    // vertical layout
    let layoutX: CGFloat = 20
    var layoutY: CGFloat = 100
    let contentWidth: CGFloat = view.bounds.size.width - (2 * layoutX)
    
    let titleLabel = makeTitleLabel("Message to Send")
    titleLabel.frame = CGRectMake(layoutX, layoutY, contentWidth, 40)
    view.addSubview(titleLabel)
    layoutY += titleLabel.frame.size.height + 10
    
    for token in TransmitViewController.tokens {
      let button = makeTokenButton(token.description)
      view.addSubview(button)
      tokenButtons.append(button)
      button.addTarget(self, action: "tokenTapped:", forControlEvents: .TouchUpInside)
      button.frame = CGRect(x: layoutX, y: layoutY, width: contentWidth, height: 44)
      layoutY += button.frame.size.height + 10
    }
    tokenButtons.first?.selected = true
    
    let playPauseButton = makePlayPauseButton("Transmit")
    playPauseButton.addTarget(self, action: "playPauseTapped:", forControlEvents: .TouchUpInside)
    playPauseButton.frame = CGRect(x: layoutX, y: layoutY + 10, width: contentWidth, height: 44)
    view.addSubview(playPauseButton)
  }
  
  @objc private func tokenTapped(sender: UIButton) {
    let index = tokenButtons.indexOf(sender)!
    let token = TransmitViewController.tokens[index]
    for button in tokenButtons {
      button.selected = false
    }
    sender.selected = true
    transmitter.token = token
  }
  
  @objc private func playPauseTapped(sender: UIButton) {
    if sender.selected {
      transmitter.stop()
    } else {
      transmitter.start()
    }
    sender.selected = !sender.selected
  }
}
