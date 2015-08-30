//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import Accelerate

private let sampleRate = 48_000.0 as Float

func decode() {
  let fftLength = 4096
  let setup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(fftLength), .FORWARD)
  
  // generate a test signal
  let inputSamples = UnsafeMutablePointer<Float>.alloc(fftLength)
  vDSP_vclr(inputSamples, 1, vDSP_Length(fftLength)) // clear to zero
  encode(0b0110011001100110, buffer: inputSamples, numSamples: fftLength)
  
  // de-interleave to get the audio input into the format that vDSP wants
  let evenSamples = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  let oddSamples = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  deinterleave(inputSamples, inputLength: fftLength, outputLeft: evenSamples, outputRight: oddSamples)
  
  // perform the DFT
  let outReal = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  let outImaginary = UnsafeMutablePointer<Float>.alloc(fftLength/2)
  vDSP_DFT_Execute(setup, evenSamples, oddSamples, outReal, outImaginary)
  
  // compute magnitudes for each frequency bin
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

private func encode(token: UInt16, buffer: UnsafeMutablePointer<Float>, numSamples: Int) {

  /// extract the bits in little-endian order
  func bits(n: UInt16) -> [Bit] {
    return
      Array(0..<16)
      .map { (n >> $0) & 0b1 }
      .map { $0 == 1 ? Bit.One : Bit.Zero }
  }

  // generate a tone for each bit that is turned on
  for (i, bit) in bits(token).enumerate() where bit == .One {
    let baseFreq = 400
    let freqSpacing = 100
    let freq = baseFreq + (i * freqSpacing)
    print("tone \(freq)")
    tone(Float(freq), buffer: buffer, numSamples: numSamples)
  }
}

/// mixes a tone with frequency 'hz' into 'buffer'
private func tone(hz: Float, buffer: UnsafeMutablePointer<Float>, numSamples: Int) {
  let x = hz * 2.0 * Float(M_PI) / sampleRate
  for i in 0..<numSamples {
    buffer[i] += sinf(Float(i) * x)
  }
}

private func bin2hertz(bin: Int, sampleRate: Float, fftLength: Int) -> Float {
  let nyquist = sampleRate / 2.0
  let numBins = fftLength / 2
  let binRatio = Float(bin) / Float(numBins)
  return nyquist * binRatio
}

