//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import AVFoundation

class Transmitter {
  let engine: AVAudioEngine
  let toneGen: AVAudioPlayerNode
  let audioFormat: AVAudioFormat
  let toneHz = 440.0
  
  init() {
    self.engine = AVAudioEngine()
    self.toneGen = AVAudioPlayerNode()
    
    self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)
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
    let x = 2.0 * Float(M_PI) / Float(sampleRate)
    for i in 0..<numFrames {
      let val = sinf(Float(toneHz) * Float(i) * x)
      bufferRaw[i] = val
    }
    pcmBuffer.frameLength = AVAudioFrameCount(numFrames)
    
    toneGen.scheduleBuffer(pcmBuffer, atTime: nil, options: []) {
      print("buffer finished playing")
    }
    
    toneGen.play()
  }
  
}