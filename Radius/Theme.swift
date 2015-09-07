//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit

struct Colors {
  static let light = UIColor(white: 0.7, alpha: 1.0)
  static let lightest = UIColor(white: 0.9, alpha: 1.0)
  static let dark = UIColor(white: 0.4, alpha: 1.0)
  static let darkest = UIColor(white: 0.2, alpha: 1.0)
  static let active = UIColor(hue: 0.9, saturation: 1.0, brightness: 1.0, alpha: 1.0)
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

func makeTitleLabel(title: String) -> UILabel {
  let label = UILabel()
  label.text = title
  label.textAlignment = .Center
  label.textColor = Colors.dark
  label.font = .systemFontOfSize(22)
  return label
}

func makeTokenButton(title: String) -> UIButton {
  let button = ThemeButton()
  button.applyThemedState(.Normal,   title: title, fgColor: Colors.dark,  bgColor: Colors.lightest)
  button.applyThemedState(.Selected, title: title, fgColor: Colors.light, bgColor: Colors.darkest)
  return button
}

func makePlayPauseButton(var playTitle: String) -> UIButton {
  let button = ThemeButton()
  button.titleLabel?.font = .boldSystemFontOfSize(20)
  playTitle = playTitle.uppercaseString
  button.applyThemedState(.Normal,   title: playTitle, fgColor: Colors.lightest, bgColor: Colors.active)
  button.applyThemedState(.Selected, title: "STOP",    fgColor: Colors.lightest, bgColor: Colors.active)
  return button
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
