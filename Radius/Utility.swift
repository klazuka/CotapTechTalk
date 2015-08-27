//
//  Copyright © 2015 Microsoft. All rights reserved.
//

import Foundation

func doDelayedOnMainThread(timeToWaitInSeconds: Float, block: Void->Void) {
  let t = dispatch_time(DISPATCH_TIME_NOW, Int64(timeToWaitInSeconds*1e9))
  dispatch_after(t, dispatch_get_main_queue(), block)
}
