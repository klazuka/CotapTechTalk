//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import AVFoundation

public class Receiver {
  private let engine: AVAudioEngine
  public var onDecodeTokenAttempt: (Token? -> Void)?
  
  public init() {
    self.engine = AVAudioEngine()
  }
  
  public func start() {
    
    guard let inputNode = engine.inputNode else {
      fatalError("no input node")
    }
    
    let accumulatorHead = FloatBuffer.alloc(fftLength)
    var accumulatorTail = accumulatorHead
    
    let desiredBufferSize = AVAudioFrameCount(1 * sampleRate) // try to grab 1 second of audio at a time
    inputNode.installTapOnBus(0, bufferSize: desiredBufferSize, format: nil) {
      pcmBuffer, time in
      
      // Collect enough audio to feed the signal decoder
      //
      // I'm lazy here and just try to collect enough input for 1 FFT.
      // In production code you would want to make this nicer,
      // the least of which would be to process all of the samples,
      // not just the first N samples.
      let numFrames = Int(pcmBuffer.frameLength)
      let numAccumulated = accumulatorTail - accumulatorHead
      let numRemaining = fftLength - numAccumulated
      let numToCopy = min(numFrames, numRemaining)
      memcpy(accumulatorTail, pcmBuffer.floatChannelData[0], numToCopy * sizeof(Float))
      accumulatorTail += numToCopy
      
      // If we have enough data, feed it into the signal decoder
      if accumulatorTail - accumulatorHead == fftLength {
        let token = decode(accumulatorHead, numSamples: fftLength)
        if let handler = self.onDecodeTokenAttempt {
          doMainThread {
            handler(token)
          }
        }
        bzero(accumulatorHead, fftLength * sizeof(Float))
        accumulatorTail = accumulatorHead
      }
    }
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
    } catch let error as NSError {
      print("audioSession setCategory error: \(error)")
    }
    
    do {
      try engine.start()
      print("Receiver started")
    } catch let error as NSError {
      print("failed to start engine: \(error)")
    }

  }
  
  public func stop() {
    if let inputNode = engine.inputNode {
      inputNode.removeTapOnBus(0)
    }
    engine.stop()
    print("Receiver stopped")
  }
}
