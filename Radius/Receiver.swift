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
    
    let accumulatorHead = FloatBuffer.alloc(fftLength)
    var accumulatorTail = accumulatorHead
    
    let desiredBufferSize = AVAudioFrameCount(1 * sampleRate) // try to grab 1 second of audio at a time
    inputNode.installTapOnBus(0, bufferSize: desiredBufferSize, format: nil) {
      pcmBuffer, time in
      
      let numFrames = Int(pcmBuffer.frameLength)
      let numAccumulated = accumulatorTail - accumulatorHead
      let numRemaining = fftLength - numAccumulated
      let numToCopy = min(numFrames, numRemaining)
//      print("got", numFrames, "copying", numToCopy)
      memcpy(accumulatorTail, pcmBuffer.floatChannelData[0], numToCopy * sizeof(Float))
      accumulatorTail += numToCopy
      
      if accumulatorTail - accumulatorHead == fftLength {
        if let token = decode(accumulatorHead, numSamples: fftLength) {
          print("got token", token)
        }
//        print("resetting accumulator")
        bzero(accumulatorHead, fftLength * sizeof(Float))
        accumulatorTail = accumulatorHead
      }
    }
    
    
    do {
      try engine.start()
      print("started")
    } catch let error as NSError {
      print("failed to start engine: \(error)")
    }

  }
  
}