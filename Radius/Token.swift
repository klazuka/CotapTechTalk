//
//  Copyright © 2015 Circle 38. All rights reserved.
//

import Foundation

/// A tiny value that can be easily transferred acoustically between devices.
struct Token {
  private let value: UInt16
  
  static let numBits = 16
  
  /// create a token from an unsigned 16-bit quantity
  init(value: UInt16) {
    self.value = value
  }
  
  /// create a token from 16 bits with the most-significant-bit first
  init(bigEndianBits bits: [Bit]) {
    precondition(bits.count == 16)
    var tempValue = 0
    for (position, bit) in bits.reverse().enumerate() {
      if bit == .One {
        tempValue |= (1 << position)
      }
    }
    self.value = UInt16(tempValue)
  }

  /// extract the bits in most-significant-bit-first order
  var bigEndianBits: [Bit] {
    return
      Array(0..<UInt16(Token.numBits)).reverse() // start with the MSB
      .map { (self.value >> $0) & 1 }            // extract the bit at each index
      .map { $0 == 1 ? Bit.One : Bit.Zero }      // convert to [Bit]
  }
}

extension Token: CustomStringConvertible {
  var description: String {
    return String(format: "0x%x", self.value)
  }
}
