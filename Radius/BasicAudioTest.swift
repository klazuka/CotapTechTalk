//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import AVFoundation


class BasicAudioTest {
  var engine = AVAudioEngine()
  var distortion = AVAudioUnitDistortion()
  var reverb = AVAudioUnitReverb()
  
  
  func start() {
    
    // Setup engine and node instances
    let input = engine.inputNode

    let fmt = input!.inputFormatForBus(0)
    print(fmt)
    
    input?.installTapOnBus(0, bufferSize: 1024, format: fmt) {
      (pcmBuffer, audioTime) in
      self.processInputBuffer(pcmBuffer)
    }
    
    do {
      try engine.start()
      print("running input loop")
    } catch let error as NSError {
      print("engine start error: \(error)")
    }
    
  }
  
  func processInputBuffer(pcmBuffer: AVAudioPCMBuffer) {
    let bufferList = pcmBuffer.audioBufferList.memory
    let bufferCoreAudio = bufferList.mBuffers
    let bufferRaw = UnsafeMutablePointer<Float32>(bufferCoreAudio.mData)
    print("got buffer of \(bufferCoreAudio.mDataByteSize) bytes")
    let numSamples = Int(bufferCoreAudio.mDataByteSize) / sizeof(Float32)
    print("got buffer of \(numSamples) samples")
    
    var minSample: Float32 = 0
    var maxSample: Float32 = 0
    
    for i in 0..<numSamples {
      let sample = bufferRaw[i]
      if sample > maxSample {
        maxSample = sample
      } else if sample < minSample {
        minSample = sample
      }
//      print(bufferRaw[i])
    }
    print("min \(minSample)")
    print("max \(maxSample)")
  }
}
