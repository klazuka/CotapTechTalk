//
//  Copyright © 2015 Microsoft. All rights reserved.
//

import Foundation
import AVFoundation

let sampleRate = 48000.0

class RadiusTransmitter {
  let engine: AVAudioEngine
  let toneGen: AVAudioPlayerNode
  let audioFormat: AVAudioFormat
  let toneHz = 440.0
  
  init() {
    self.engine = AVAudioEngine()
    self.toneGen = AVAudioPlayerNode()
    
    self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
    self.engine.attachNode(self.toneGen)
    self.engine.connect(self.toneGen, to: self.engine.outputNode, format: self.audioFormat)
  }
  
  func start() {
    
    do {
      try engine.start()
      print("started")
    } catch let error as NSError {
      print("failed to start engine: \(error)")
    }
    
    let pcmBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat,
                                     frameCapacity: AVAudioFrameCount(10 * sampleRate))
    
    let bufferRaw = pcmBuffer.floatChannelData[0]
    let numFrames = Int(pcmBuffer.frameCapacity)
    for i in 0..<numFrames {
      let val = sinf(Float(toneHz) * Float(i) * 2 * Float(M_PI) / Float(sampleRate))
      bufferRaw[i] = val
    }
    
    toneGen.scheduleBuffer(pcmBuffer, atTime: nil, options: []) {
      print("buffer finished playing")
    }
    
    toneGen.play()
  }
  
}