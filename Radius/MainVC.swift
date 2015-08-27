//
//  Copyright © 2015 Microsoft. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.lightGrayColor()
    
//    let tx = RadiusTransmitter()
        let tx = BasicAudioTest()
    
    tx.start()
  }
}

