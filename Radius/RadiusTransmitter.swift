//
//  Copyright © 2015 Microsoft. All rights reserved.
//

import Foundation
import AVFoundation

let sampleRate = 48000.0

class RadiusTransmitter {
  let engine: AVAudioEngine
  let toneGen: AVAudioPlayerNode
  let outFormat: AVAudioFormat
  let toneHz = 440.0
  
  init() {
    self.outFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
    
    self.engine = AVAudioEngine()
    self.toneGen = AVAudioPlayerNode()
    
    self.engine.attachNode(self.toneGen)
    self.engine.connect(self.toneGen, to: self.engine.outputNode, format: self.outFormat)
  }
  
  func start() {
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
    } catch let error as NSError {
      print("audioSession setCategory error: \(error)")
    }
    
    let ioBufferDuration = 128.0 / sampleRate
    
    do {
      try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
    } catch let error as NSError {
      print("audioSession setup error: \(error)")
    }
    
    
    do {
      try engine.start()
      print("started")
    } catch let error as NSError {
      print("failed to start engine: \(error)")
    }
    
    let bufferFrameCount = Int(ceil(sampleRate / toneHz))
    
    let pcmBuffer = AVAudioPCMBuffer(PCMFormat: outFormat, frameCapacity: AVAudioFrameCount(bufferFrameCount))
    
    let bufferList = pcmBuffer.audioBufferList.memory
    let bufferCoreAudio = bufferList.mBuffers
    let bufferRaw = UnsafeMutablePointer<Float32>(bufferCoreAudio.mData)
    
    for i in 0..<bufferFrameCount {
      bufferRaw[i] = Float(i) / Float(bufferFrameCount)
    }
    
    toneGen.scheduleBuffer(pcmBuffer, atTime: nil, options: .Loops) {
      print("buffer finished playing")
    }
  }
  
}