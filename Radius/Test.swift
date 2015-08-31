//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation

func doTest() {
  // consistent random seed for predictable noise test results
  srand48(42);
  
  // generate a test signal
  let inputSamples = FloatBuffer.alloc(fftLength)
  bzero(inputSamples, fftLength)
  encode(Token(value: 0xabcd), buffer: inputSamples, numSamples: fftLength)
  addNoise(10.0, buffer: inputSamples, numSamples: fftLength) // TODO remove this testing impediment
  
  // decode it
  let token = decode(inputSamples, numSamples: fftLength)
  print("decoded token as \(token)")
  
  inputSamples.dealloc(fftLength)
}
