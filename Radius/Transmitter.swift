//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import AVFoundation
import AudioBarcodeKit

class Transmitter {
  let engine: AVAudioEngine
  let toneGen: AVAudioPlayerNode
  let audioFormat: AVAudioFormat
  
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
    
    encode(Token(0x8001), buffer: bufferRaw, numSamples: numFrames)
    
    pcmBuffer.frameLength = AVAudioFrameCount(numFrames)
    
    toneGen.scheduleBuffer(pcmBuffer, atTime: nil, options: []) {
      print("buffer finished playing")
    }
    
    toneGen.play()
  }
  
}