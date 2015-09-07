//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit
import AudioBarcodeKit


class ReceiveViewController: UIViewController {
  let receiver = Receiver()
  let tokenLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    receiver.onTokenReceivedHandler = { token in
      self.tokenLabel.text = token.description
    }
  }
  
  private func setupUI() {
    view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    
    // centered layout of the most-recently received token and the play/pause button at the bottom
    let layoutX: CGFloat = 20
    var layoutY: CGFloat = 100
    let contentWidth: CGFloat = view.bounds.size.width - (2 * layoutX)
    
    let titleLabel = makeTitleLabel("Last Message Received")
    titleLabel.frame = CGRectMake(layoutX, layoutY, contentWidth, 40)
    view.addSubview(titleLabel)
    layoutY += titleLabel.frame.size.height + 10
    
    tokenLabel.font = .boldSystemFontOfSize(40)
    tokenLabel.backgroundColor = .whiteColor()
    tokenLabel.textColor = Colors.dark
    tokenLabel.text = "------"
    tokenLabel.textAlignment = .Center
    tokenLabel.layer.borderColor = Colors.light.CGColor
    tokenLabel.layer.borderWidth = 4
    tokenLabel.frame = CGRect(x: layoutX, y: layoutY, width: contentWidth, height: 100)
    view.addSubview(tokenLabel)
    layoutY += tokenLabel.frame.size.height + 20
    
    let playPauseButton = makePlayPauseButton("Receive")
    playPauseButton.addTarget(self, action: "playPauseTapped:", forControlEvents: .TouchUpInside)
    playPauseButton.frame = CGRect(x: layoutX, y: layoutY + 10, width: contentWidth, height: 44)
    view.addSubview(playPauseButton)
  }
  
  @objc private func playPauseTapped(sender: UIButton) {
    if sender.selected {
      receiver.stop()
      tokenLabel.text = "------"
    } else {
      receiver.start()
    }
    sender.selected = !sender.selected
  }
}
