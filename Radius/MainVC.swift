//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: UIViewController {
  
//  let system = Transmitter()
//  let system = Receiver()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .lightGrayColor()
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
      print("set audio session category")
    } catch let error as NSError {
      print("audioSession setCategory error: \(error)")
    }
    
    doTest()
    
//    system.start()
//    FMSynthesizer.start()
  }
}

