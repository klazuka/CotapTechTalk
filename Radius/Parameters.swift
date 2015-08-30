//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation


// Global parameters that define the protocol between the transmitter and the receiver
// These can be tweaked, although they are not purely independent (for instance,
// `fftLength` determines the frequencies that can be resolved, so you may need
// to increase/decrease `binStride` to keep the right distance between tones)
let sampleRate: Float = 48_000.0
let fftLength: Int = 4096
let baseFreq: Float = 400.0  // this must be well below half of the sample rate
let binStride: Int = 4   // number of bins between tones
