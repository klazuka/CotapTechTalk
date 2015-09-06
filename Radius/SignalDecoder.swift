//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation
import Accelerate

/// decode a buffer of time-domain audio samples into a Token
/// according to the "audio barcode" protocol
public func decode(inputSamples: FloatBuffer, numSamples: Int) -> Token? {
  assert(numSamples == fftLength)
  let setup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(fftLength), .FORWARD)
  
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
  let token = decodeStage2(freqMagnitudes, numMagnitudes: fftLength/2)
  
  // free memory
  vDSP_DFT_DestroySetup(setup)
  
  evenSamples.dealloc(fftLength/2)
  oddSamples.dealloc(fftLength/2)
  outReal.dealloc(fftLength/2)
  outImaginary.dealloc(fftLength/2)
  freqMagnitudes.dealloc(fftLength/2)

  return token
}

/// given the frequency-domain samples of the "audio barcode", attempt
/// to decode a token.
private func decodeStage2(magnitudes: FloatBuffer, numMagnitudes: Int) -> Token? {
    
  var bits = [Bit]()
  
  // estimate the noise floor by using the magnitude in nearby bins, which should be devoid of signal
  let preBins = [firstToneBin-7, firstToneBin-6, firstToneBin-5]
  let postBins = [lastToneBin+5, lastToneBin+6, lastToneBin+7]
  let noiseFloor = (preBins + postBins)
                    .map { magnitudes[$0] }
                    .mean()
  
  // find the strength of the signal
  var peak: Float = 0.0
  for bin in toneBins {
    peak = max(peak, magnitudes[bin])
  }
  
  // bail out early if the signal isn't strong enough
  if peak/noiseFloor < 20.0 {
    return nil
  }
  
  // set the hard-decision threshold to be above the noise floor
  // but also not too high that it would reject weak tones
  let threshold = 0.3 * (peak - noiseFloor)
  print("threshold \(threshold)")
  
  // decide which tones are present and which are not
  for bin in toneBins {
    let magnitude = magnitudes[bin]
//    print(String(format: "%4d %5.0f %.0f", bin, bin2hertz(bin), magnitude))
    let isOn = magnitude > threshold
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

/// split `input` apart into `outputLeft` and `outputRight`, where the even indices
/// go into the left part and the odd indices go into the right part
private func deinterleave(input: UnsafePointer<Float>, inputLength: Int, outputLeft: FloatBuffer, outputRight: FloatBuffer) {
  // de-interleave the real samples by abusing vDSP's complex-number deinterleave function
  var out = DSPSplitComplex(realp: outputLeft, imagp: outputRight)
  vDSP_ctoz(UnsafePointer<DSPComplex>(input), 2, &out, 1, vDSP_Length(inputLength/2))
}
