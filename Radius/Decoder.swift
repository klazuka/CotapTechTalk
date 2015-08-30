//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import Accelerate

// one tone per bit used to represent a token
private let numTones = Token.numBits

// derived constants
private let startBin = hertz2bin(Float(baseFreq))
private let freqSpacing = bin2hertz(startBin + binStride) - bin2hertz(startBin)
private let lastBin = startBin + (numTones * binStride)
private let toneBins = startBin.stride(to: lastBin, by: binStride)


typealias FloatBuffer = UnsafeMutablePointer<Float>

func doTest() {
  // consistent random seed for predictable noise test results
  srand48(42);
  
  let setup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(fftLength), .FORWARD)
  
  // generate a test signal
  let inputSamples = FloatBuffer.alloc(fftLength)
  vDSP_vclr(inputSamples, 1, vDSP_Length(fftLength)) // clear to zero
  encode(Token(value: 0b0110011001100110), buffer: inputSamples, numSamples: fftLength)
  addNoise(5.85, buffer: inputSamples, numSamples: fftLength) // TODO remove this testing impediment
  
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
//  printFrequencyAnalysis(freqMagnitudes, numMagnitudes: fftLength/2)
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

private func encode(token: Token, buffer: FloatBuffer, numSamples: Int) {
  print("Encoding signal for Token \(token)")
  
  // generate a tone for each bit that is turned on
  for (i, bit) in token.bigEndianBits.enumerate() where bit == .One {
    let freq = baseFreq + (Float(i) * freqSpacing)
    print("set tone \(freq)")
    tone(Float(freq), buffer: buffer, numSamples: numSamples)
  }
}

private func decode(magnitudes: FloatBuffer, numMagnitudes: Int) -> Token {
    
  var bits = [Bit]()
  for bin in toneBins {
    let magnitude = magnitudes[bin]
    print(String(format: "%4d %5.0f %.0f", bin, bin2hertz(bin), magnitude))
    let isOn = magnitude > 200_000
    bits.append(isOn ? .One : .Zero)
  }
  
  return Token(bigEndianBits: bits)
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

private func addNoise(noise: Float, buffer: FloatBuffer, numSamples: Int) {
  
  for i in 0..<numSamples {
    let normRandom = Float(drand48())         // range [0, 1]
    let negToPosRandom = (normRandom * 2) - 1 // range of [-1, 1]
    let r = noise * negToPosRandom            // attenuate the noise
//    print("ratio", abs(r) / abs(buffer[i]))
    buffer[i] += r
  }
}

private func deinterleave(input: UnsafePointer<Float>, inputLength: Int, outputLeft: FloatBuffer, outputRight: FloatBuffer) {
  
  // de-interleave the real samples by abusing vDSP's complex-number deinterleave function
  var out = DSPSplitComplex(realp: outputLeft, imagp: outputRight)
  vDSP_ctoz(UnsafePointer<DSPComplex>(input), 2, &out, 1, vDSP_Length(inputLength/2))
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


