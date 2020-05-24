import Foundation

extension Character {
  var isValidCharacter: Bool {
    isLetter || isNumber || isEmoji
  }

  var isEmoji: Bool {
    !unicodeScalars.filter({ $0.isEmoji }).isEmpty
  }
}

extension UnicodeScalar {
  var isEmoji: Bool {
    switch value {
    case 0x1F600...0x1F64F, // Emoticons
    0x1F300...0x1F5FF, // Misc Symbols and Pictographs
    0x1F680...0x1F6FF, // Transport and Map
    0x2600...0x26FF,   // Misc symbols
    0x2700...0x27BF,   // Dingbats
    0xFE00...0xFE0F,   // Variation Selectors
    0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
    65024...65039, // Variation selector
    8400...8447: // Combining Diacritical Marks for Symbols
      return true
    default: return false
    }
  }

  var isZeroWidthJoiner: Bool {

    return value == 8205
  }
}
