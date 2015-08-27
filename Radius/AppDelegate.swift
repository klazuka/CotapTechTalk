//
//  Copyright © 2015 Microsoft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    
    let vc = MainVC()
    window?.rootViewController = vc
    window?.makeKeyAndVisible()

    return true
  }
}

