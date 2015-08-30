//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import Accelerate

// we will be transmitting a 16-bit token
typealias Token = UInt16
private let numTones = 16 // one tone per bit used to represent a token


// derived constants
private let startBin = hertz2bin(Float(baseFreq))
private let freqSpacing = bin2hertz(startBin + binStride) - bin2hertz(startBin)
private let lastBin = startBin + (numTones * binStride)


typealias FloatBuffer = UnsafeMutablePointer<Float>

func doTest() {
  let setup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(fftLength), .FORWARD)
  
  // generate a test signal
  let inputSamples = FloatBuffer.alloc(fftLength)
  vDSP_vclr(inputSamples, 1, vDSP_Length(fftLength)) // clear to zero
  encode(0b0110011001100110, buffer: inputSamples, numSamples: fftLength)
  
  // de-interleave to get the audio input into the format that vDSP wants
  let evenSamples = FloatBuffer.alloc(fftLength/2)
  let oddSamples = FloatBuffer.alloc(fftLength/2)
  deinterleave(inputSamples, inputLength: fftLength, outputLeft: evenSamples, outputRight: oddSamples)
  
  // perform the DFT
  let outReal = FloatBuffer.alloc(fftLength/2)
  let outImaginary = FloatBuffer.alloc(fftLength/2)
  vDSP_DFT_Execute(setup, evenSamples, oddSamples, outReal, outImaginary)
  
  // compute magnitudes for each frequency bin (convert from complex to real)
  var freqComplex = DSPSplitComplex(realp: outReal, imagp: outImaginary)
  let freqMagnitudes = FloatBuffer.alloc(fftLength/2)
  vDSP_zvmags(&freqComplex, 1, freqMagnitudes, 1, vDSP_Length(fftLength/2))
  
  // analyze
  printFrequencyAnalysis(freqMagnitudes, numMagnitudes: fftLength/2)
  print("decoded as", decode(freqMagnitudes, numMagnitudes: fftLength/2))
  
  // free memory
  vDSP_DFT_DestroySetup(setup)
  inputSamples.dealloc(fftLength)
  evenSamples.dealloc(fftLength/2)
  oddSamples.dealloc(fftLength/2)
  outReal.dealloc(fftLength/2)
  outImaginary.dealloc(fftLength/2)
  freqMagnitudes.dealloc(fftLength/2)
}

private func printFrequencyAnalysis(magnitudes: FloatBuffer, numMagnitudes: Int) {
  print(" bin  freq magnitude")
  print(" ---  ---- ---------")
  for i in 0..<numMagnitudes {
    let freq = bin2hertz(i)
    let magnitude = magnitudes[i]
    print(String(format: "%4d %5.0f %.0f", i, freq, magnitude))
  }
}

private func decode(magnitudes: FloatBuffer, numMagnitudes: Int) -> UInt16 {
  
  print("start bin \(startBin)", magnitudes[startBin])
  print("last bin \(lastBin)", magnitudes[lastBin])
  
  return 0
}

private func deinterleave(input: UnsafePointer<Float>, inputLength: Int, outputLeft: FloatBuffer, outputRight: FloatBuffer) {
  
  // de-interleave the real samples by abusing vDSP's complex-number deinterleave function
  var out = DSPSplitComplex(realp: outputLeft, imagp: outputRight)
  vDSP_ctoz(UnsafePointer<DSPComplex>(input), 2, &out, 1, vDSP_Length(inputLength/2))
}

private func encode(token: UInt16, buffer: FloatBuffer, numSamples: Int) {

  /// extract the bits in little-endian order
  func bits(n: UInt16) -> [Bit] {
    return
      Array(0..<16)
      .map { (n >> $0) & 0b1 }
      .map { $0 == 1 ? Bit.One : Bit.Zero }
  }

  // generate a tone for each bit that is turned on
  for (i, bit) in bits(token).enumerate() where bit == .One {
    let freq = baseFreq + (Float(i) * freqSpacing)
    print("set tone \(freq)")
    tone(Float(freq), buffer: buffer, numSamples: numSamples)
  }
}

/// mixes a tone with frequency 'hz' into 'buffer'
private func tone(hz: Float, buffer: FloatBuffer, numSamples: Int) {
  let x = hz * 2.0 * Float(M_PI) / sampleRate
  for i in 0..<numSamples {
    buffer[i] += sinf(Float(i) * x)
  }
}

private func bin2hertz(bin: Int) -> Float {
  let nyquist = sampleRate / 2.0
  let numBins = fftLength / 2
  let binRatio = Float(bin) / Float(numBins)
  return nyquist * binRatio
}

private func hertz2bin(hertz: Float) -> Int {
  let nyquist = sampleRate / 2.0
  let numBins = fftLength / 2
  let bin = (hertz / nyquist) * Float(numBins)
  return Int(round(bin))
}

