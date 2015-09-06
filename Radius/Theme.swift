//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit

struct Colors {
  static let light = UIColor(white: 0.7, alpha: 1.0)
  static let lighter = UIColor(white: 0.8, alpha: 1.0)
  static let lightest = UIColor(white: 0.9, alpha: 1.0)
  static let dark = UIColor(white: 0.4, alpha: 1.0)
  static let darker = UIColor(white: 0.3, alpha: 1.0)
  static let darkest = UIColor(white: 0.2, alpha: 1.0)
}

typealias ButtonState = (title: String, fgColor: UIColor, bgColor: UIColor)

class ThemeButton: UIButton {
  func applyThemedState(state: UIControlState, title: String, fgColor: UIColor, bgColor: UIColor) {
    layer.cornerRadius = 3
    clipsToBounds = true
    setTitle(title, forState: state)
    setTitleColor(fgColor, forState: state)
    setBackgroundImage(color2image(bgColor), forState: state)
  }
}

class TokenButton: ThemeButton {
  required init?(coder aDecoder: NSCoder) { fatalError("not implemented") }
  
  init(title: String) {
    super.init(frame: .zero)
    applyThemedState(.Normal,   title: title, fgColor: Colors.dark, bgColor: Colors.lightest)
    applyThemedState(.Selected, title: title, fgColor: Colors.light, bgColor: Colors.darkest)
  }
}

class PlayPauseButton: ThemeButton {
  required init?(coder aDecoder: NSCoder) { fatalError("not implemented") }
  
  init() {
    super.init(frame: .zero)
    applyThemedState(.Normal,   title: "Play", fgColor: Colors.light, bgColor: Colors.darkest)
    applyThemedState(.Selected, title: "Stop", fgColor: Colors.darkest, bgColor: Colors.light)
  }
}

private func color2image(color: UIColor) -> UIImage {
  let rect = CGRectMake(0, 0, 1, 1)
  UIGraphicsBeginImageContext(rect.size)
  let ctx = UIGraphicsGetCurrentContext()!
  color.setFill()
  CGContextFillRect(ctx, rect)
  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  return image
}
