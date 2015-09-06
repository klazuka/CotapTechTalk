//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import AVFoundation
import AudioBarcodeKit

class Receiver {
  let engine: AVAudioEngine
  
  init() {
    self.engine = AVAudioEngine()
  }
  
  func start() {
    
    guard let inputNode = engine.inputNode else {
      fatalError("no input node")
    }
    
    let desiredBufferSize = AVAudioFrameCount(10 * sampleRate)
    inputNode.installTapOnBus(0, bufferSize: desiredBufferSize, format: nil) {
      pcmBuffer, time in
      
      let numFrames = Int(pcmBuffer.frameLength)
      var numCrossings = 0
      var previousSample = 0 as Float
      for i in 0..<numFrames {
        let sample = pcmBuffer.floatChannelData[0][i]
        if sample < 0 && previousSample >= 0 {
          numCrossings++
        } else if sample >= 0 && previousSample < 0 {
          numCrossings++
        }
        previousSample = sample
      }
      print("num zero crossings", numCrossings)
    }
    
    
    do {
      try engine.start()
      print("started")
    } catch let error as NSError {
      print("failed to start engine: \(error)")
    }

  }
  
}