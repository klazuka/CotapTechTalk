//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    
    let tabs = UITabBarController()
    let tx = TransmitViewController()
    tx.title = "Transmit"
    let rx = ReceiveViewController()
    rx.title = "Receive"
    tabs.viewControllers = [tx, rx]
    
    window?.rootViewController = tabs
    window?.makeKeyAndVisible()

    return true
  }
}

