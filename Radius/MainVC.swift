//
//  Copyright © 2015 Microsoft. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: UIViewController {
  
  let tx = RadiusTransmitter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .lightGrayColor()
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
      print("set audio session category")
    } catch let error as NSError {
      print("audioSession setCategory error: \(error)")
    }
    
    tx.start()
//    FMSynthesizer.start()
  }
}

