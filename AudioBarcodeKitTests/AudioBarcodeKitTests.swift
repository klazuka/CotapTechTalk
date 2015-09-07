//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import XCTest
@testable import AudioBarcodeKit

class AudioBarcodeKitTests: XCTestCase {
  

  
  func testSimple() {
    // consistent random seed for predictable noise test results
    srand48(42);
    
//    let testValues: [UInt16] = [0x8000]
    let testValues: [UInt16] = [0x8001, 0x1234, 0x4444, 0x2828]
    let testNoiseLevels: [Float] = [0, 1]
//    let testNoiseLevels: [Float] = [0]
    
    for val in testValues {
      for noise in testNoiseLevels {
        let inputToken = Token(val)
        if let outputToken = encodeAndDecode(inputToken, noise: noise) {
          XCTAssertEqual(inputToken, outputToken)
        } else {
          XCTFail("failed to decode token")
        }
        
      }
    }
    
    print("all done")
  }
  
}


func encodeAndDecode(inputToken: Token, noise: Float? = nil) -> Token? {
  print("running test", inputToken, "noise", noise)
  
  // generate a test signal
  let inputSamples = FloatBuffer.alloc(fftLength)
  bzero(inputSamples, fftLength * sizeof(Float))
  encode(inputToken, buffer: inputSamples, numSamples: fftLength)
  if let noise = noise {
    addNoise(noise, buffer: inputSamples, numSamples: fftLength)
  }
  
  // decode it
  let outputToken = decode(inputSamples, numSamples: fftLength)
  inputSamples.dealloc(fftLength)
  return outputToken
}

/// simulate a noisy signal
func addNoise(noise: Float, buffer: FloatBuffer, numSamples: Int) {
  
  for i in 0..<numSamples {
    let normRandom = Float(drand48())         // range [0, 1]
    let negToPosRandom = (normRandom * 2) - 1 // range of [-1, 1]
    let r = noise * negToPosRandom            // attenuate the noise
    //    print("ratio", abs(r) / abs(buffer[i]))
    buffer[i] += r
  }
}
