//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit
import AudioBarcodeKit


class TransmitViewController: UIViewController {
  
  static var tokens = [0x1234, 0xabcd, 0x7777, 0xaaaa].map(Token.init)
  var tokenButtons = [UIButton]() // must be same order as the tokens
  let transmitter = Transmitter(token: tokens[0])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    
    // vertical layout of buttons
    let layoutX: CGFloat = 20
    var layoutY: CGFloat = 100
    let contentWidth: CGFloat = view.bounds.size.width - (2 * layoutX)
    
    for token in TransmitViewController.tokens {
      let button = TokenButton(title: token.description)
      view.addSubview(button)
      tokenButtons.append(button)
      button.tag = Int(token.value)
      button.addTarget(self, action: "tokenTapped:", forControlEvents: .TouchUpInside)
      button.frame = CGRect(x: layoutX, y: layoutY, width: contentWidth, height: 44)
      layoutY += button.frame.size.height + 10
    }
    tokenButtons.first?.selected = true
    
    let playPauseButton = PlayPauseButton(playTitle: "Transmit")
    playPauseButton.addTarget(self, action: "playPauseTapped:", forControlEvents: .TouchUpInside)
    playPauseButton.frame = CGRect(x: layoutX, y: layoutY + 10, width: contentWidth, height: 44)
    view.addSubview(playPauseButton)
  }
  
  @objc private func tokenTapped(sender: UIButton) {
    let index = tokenButtons.indexOf(sender)!
    let token = TransmitViewController.tokens[index]
    print("selected token", token)
    for button in tokenButtons where button !== sender {
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
