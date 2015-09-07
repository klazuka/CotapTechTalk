//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation

func doMainThread(block: Void->Void) {
  dispatch_async(dispatch_get_main_queue(), block)
}

func doDelayedOnMainThread(timeToWaitInSeconds: Float, block: Void->Void) {
  let t = dispatch_time(DISPATCH_TIME_NOW, Int64(timeToWaitInSeconds*1e9))
  dispatch_after(t, dispatch_get_main_queue(), block)
}

extension CollectionType where Generator.Element == Float {
  func mean() -> Float {
    let sum = self.reduce(0.0, combine: +)
    let total = numericCast(self.count) as Int64
    return sum / Float(total)
  }
}
