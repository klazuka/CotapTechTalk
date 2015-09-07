//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation

/// generates a buffer of 32-bit float audio samples where the
/// provided `token` is encoded in the frequency domain
/// according to the "audio barcode" protocol.
public func encode(token: Token, buffer: FloatBuffer, numSamples: Int) {
  print("Encoding signal for Token \(token)")
  
  // generate a tone for each bit that is turned on
  for (i, bit) in token.bigEndianBits.enumerate() where bit == .One {
    let freq = baseFreq + (Float(i) * freqSpacing)
    print("set tone \(freq)")
    tone(Float(freq), buffer: buffer, numSamples: numSamples)
  }
  
  // normalize to range [-1.0, +1.0]
  let max = UnsafeBufferPointer(start: buffer, count: numSamples).maxElement()!
  for i in 0..<numSamples {
    buffer[i] /= max
  }
}

/// mixes a tone with frequency 'hz' into 'buffer'
private func tone(hz: Float, buffer: FloatBuffer, numSamples: Int) {
  let x = hz * 2.0 * Float(M_PI) / sampleRate
  for i in 0..<numSamples {
    buffer[i] += sinf(Float(i) * x)
  }
}
