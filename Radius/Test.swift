//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import AudioBarcodeKit

func internalTest(inputToken: Token, noise: Float? = nil) {
  
  print("running test", inputToken, "noise", noise ?? 0)
  
  // generate a test signal
  let inputSamples = FloatBuffer.alloc(fftLength)
  bzero(inputSamples, fftLength * sizeof(Float))
  encode(inputToken, buffer: inputSamples, numSamples: fftLength)
  if let noise = noise {
    addNoise(noise, buffer: inputSamples, numSamples: fftLength)
  }
  
  // decode it
  let outputToken = decode(inputSamples, numSamples: fftLength)
  print("decoded token as \(outputToken)")
  if outputToken.value != inputToken.value {
    print("input", inputToken, "does not equal output", outputToken)
    fatalError("test failed")
  }
  
  inputSamples.dealloc(fftLength)
}

func doTest() {
  // consistent random seed for predictable noise test results
  srand48(42);
  
  let testValues: [UInt16] = [0x1234, 0xabcd, 0x7777, 0xeeee]
  let testNoiseLevels: [Float] = [0, 1, 5, 10]
  
  for val in testValues {
    for noise in testNoiseLevels {
      internalTest(Token(value: val), noise: noise)
    }
  }
  
  print("all done")
}

/// simulate a noisy signal
private func addNoise(noise: Float, buffer: FloatBuffer, numSamples: Int) {
  
  for i in 0..<numSamples {
    let normRandom = Float(drand48())         // range [0, 1]
    let negToPosRandom = (normRandom * 2) - 1 // range of [-1, 1]
    let r = noise * negToPosRandom            // attenuate the noise
    //    print("ratio", abs(r) / abs(buffer[i]))
    buffer[i] += r
  }
}
