//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.tintColor = Colors.active
    
    let tabs = UITabBarController()
    let tx = TransmitViewController()
    tx.tabBarItem = UITabBarItem(title: "Transmit", image: UIImage(named: "tx_tab_icon"), selectedImage: nil)
    
    let rx = ReceiveViewController()
    rx.tabBarItem = UITabBarItem(title: "Receive", image: UIImage(named: "rx_tab_icon"), selectedImage: nil)
    tabs.viewControllers = [tx, rx]
    
    window?.rootViewController = tabs
    window?.makeKeyAndVisible()

    return true
  }
}

