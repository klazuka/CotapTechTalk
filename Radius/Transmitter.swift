//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import AVFoundation
import AudioBarcodeKit

class Transmitter {
  private let engine: AVAudioEngine
  private let toneGen: AVAudioPlayerNode
  private let audioFormat: AVAudioFormat
  var token: Token
  
  init(token: Token) {
    self.token = token
    self.engine = AVAudioEngine()
    self.toneGen = AVAudioPlayerNode()
    
    self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)
    self.engine.attachNode(self.toneGen)
    self.engine.connect(self.toneGen, to: self.engine.outputNode, format: self.audioFormat)
  }
  
  func start() {
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
    } catch let error as NSError {
      print("audioSession setCategory error: \(error)")
    }
    
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
    
    encode(token, buffer: bufferRaw, numSamples: numFrames)
    pcmBuffer.frameLength = AVAudioFrameCount(numFrames)
    
    toneGen.scheduleBuffer(pcmBuffer, atTime: nil, options: .Loops) {
      print("buffer finished playing")
    }
    
    toneGen.play()
  }
  
  func stop() {
    toneGen.stop()
    engine.stop()
  }
}

