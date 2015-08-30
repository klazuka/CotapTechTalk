//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import Accelerate

private let sampleRate = 48_000.0 as Float

func decode() {
  let fftLength = 256
  let setup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(fftLength), .FORWARD)
  
  let inputSamples = UnsafeMutablePointer<Float>.alloc(fftLength)
  tone(440, buffer: inputSamples, numSamples: fftLength)
  
  let evenSamples = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  let oddSamples = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  deinterleave(inputSamples, inputLength: fftLength, outputLeft: evenSamples, outputRight: oddSamples)
  
  let outReal = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  let outImaginary = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  vDSP_DFT_Execute(setup, evenSamples, oddSamples, outReal, outImaginary)
  
  // compute magnitudes for each bin
  var freqComplex = DSPSplitComplex(realp: outReal, imagp: outImaginary)
  let freqMagnitudes = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  vDSP_zvmags(&freqComplex, 1, freqMagnitudes, 1, vDSP_Length(fftLength/2))
  
  // print out the analysis
  print(" bin  freq magnitude")
  print(" ---  ---- ---------")
  for i in 0..<fftLength/2 {
    let freq = bin2hertz(i, sampleRate: sampleRate, fftLength: fftLength)
    let magnitude = freqMagnitudes[i]
    print(String(format: "%4d %5.0f %.0f", i, freq, magnitude))
  }
  
  // free memory
  vDSP_DFT_DestroySetup(setup)
  inputSamples.dealloc(fftLength)
  evenSamples.dealloc(fftLength/2)
  oddSamples.dealloc(fftLength/2)
  outReal.dealloc(fftLength/2)
  outImaginary.dealloc(fftLength/2)
  freqMagnitudes.dealloc(fftLength/2)
}

private func deinterleave(input: UnsafePointer<Float>, inputLength: Int, outputLeft: UnsafeMutablePointer<Float>, outputRight: UnsafeMutablePointer<Float>) {
  
  // de-interleave the real samples by abusing vDSP's complex-number deinterleave function
  var out = DSPSplitComplex(realp: outputLeft, imagp: outputRight)
  vDSP_ctoz(UnsafePointer<DSPComplex>(input), 2, &out, 1, vDSP_Length(inputLength/2))
}

// TODO consider using UnsafeMutableBufferPointer
private func tone(hz: Float, buffer: UnsafeMutablePointer<Float>, numSamples: Int) {
  let x = hz * 2.0 * Float(M_PI) / sampleRate
  
  for i in 0..<numSamples {
    buffer[i] = sinf(Float(i) * x)
  }
}

private func bin2hertz(bin: Int, sampleRate: Float, fftLength: Int) -> Float {
  let nyquist = sampleRate / 2.0
  let numBins = fftLength / 2
  let binRatio = Float(bin) / Float(numBins)
  return nyquist * binRatio
}

