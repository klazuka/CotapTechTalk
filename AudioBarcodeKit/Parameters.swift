//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation


// MARK:- The protocol parameters (somewhat tweakable)

// Global parameters that define the protocol between the transmitter and the receiver
// These can be tweaked, although they are not purely independent (for instance,
// `fftLength` determines the frequencies that can be resolved, so you may need
// to increase/decrease `binStride` to keep enough space between tones)

let sampleRate: Float = 44_100.0 // a typical sample rate for audio systems. In theory this could be changed, but you will probably need to do add sample rate conversion in between you and AVAudioEngine
let baseFreq: Float = 843.8      // this must be well below half of the sample rate. ideally it is in the center of a bin so that most of the waveforms energy lands in this bin and not the neighboring ones
let fftLength: Int = 4096        // the higher the FFT length, the higher frequency resolution, but increases latency and increases CPU/memory usage
let toneBinStride: Int = 8       // number of spacer bins between tones


// MARK:- Derived Parameters (do not tweak)

// derived constants
let firstToneBin = hertz2bin(Float(baseFreq))
let freqSpacing = bin2hertz(firstToneBin + toneBinStride) - bin2hertz(firstToneBin)
let lastToneBin = firstToneBin + ((Token.numBits-1) * toneBinStride)
let toneBins = firstToneBin.stride(through: lastToneBin, by: toneBinStride)


// MARK:- Utility

/// given the index of a frequency bin, returns the frequency in the middle of the bin
func bin2hertz(bin: Int) -> Float {
  let nyquist = sampleRate / 2.0
  let numBins = fftLength / 2
  let binRatio = Float(bin) / Float(numBins)
  return nyquist * binRatio
}

/// given a frequency, returns the nearest bin
func hertz2bin(hertz: Float) -> Int {
  let nyquist = sampleRate / 2.0
  let numBins = fftLength / 2
  let bin = (hertz / nyquist) * Float(numBins)
  return Int(round(bin))
}

// MARK:- Other

/// a more concise name for the pointer to buffers of our audio data
typealias FloatBuffer = UnsafeMutablePointer<Float>
