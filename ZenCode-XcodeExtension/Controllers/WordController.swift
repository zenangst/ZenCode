import Foundation
import XcodeKit

class WordController {
  func findWordBoundaries(start: inout Int, modifier: (inout Int) -> Void, scope: String) {
    var foundWordBondary = false
    while !foundWordBondary {
      if start >= scope.count {
        foundWordBondary = true
        break
      } else {
        let character: Character = scope[start]
        if !character.isValidCharacter {
          foundWordBondary = true
          break
        }

        let previousStart = start
        modifier(&start)
        if start < 0 || start > scope.count - 1 {
          start = previousStart
          foundWordBondary = true
        }
      }
    }
  }

  func findPreviousWord(startLine: inout Int, endLine: inout Int,
                        column: inout Int, contents: [String]) -> (column: Int, line: Int, currentScope: String) {
    var currentScope = contents[startLine...endLine].joined()
    var currentLetter: Character = currentScope[column]
    if !currentLetter.isValidCharacter {
      var foundWordStart = false
      while !foundWordStart {
        if column < 0 {
          column = 0
          if startLine == 0 {
            foundWordStart = true
            break
          }

          startLine -= 1
          endLine -= 1
          column = contents[startLine].count - 1
          let ctx = findPreviousWord(startLine: &startLine, endLine: &endLine,
                                     column: &column, contents: contents)
          column = ctx.column
          currentScope = ctx.currentScope
          foundWordStart = true
          break
        }

        currentLetter = currentScope[column]
        if currentLetter.isValidCharacter {
          foundWordStart = true
          break
        } else {
          column -= 1
        }
      }
    }

    return (column: column, line: startLine, currentScope: currentScope)
  }

  func findNextWord(startLine: inout Int, endLine: inout Int,
                    column: inout Int, contents: [String]) -> (column: Int, line: Int, currentScope: String) {
    var currentScope = contents[startLine...endLine].joined()
    let upperbounds = currentScope.count
    var currentLetter: Character = currentScope[column]
    if !currentLetter.isValidCharacter {
      var foundWordStart = false
      while !foundWordStart {
        if column >= upperbounds {
          column = 0
          if startLine + 1 == contents.count {
            foundWordStart = true
          } else {
            startLine += 1
            endLine += 1
            let ctx = findNextWord(startLine: &startLine, endLine: &endLine,
                                   column: &column, contents: contents)
            currentScope = ctx.currentScope
            foundWordStart = true
          }
        } else {
          currentLetter = currentScope[column]
          if currentLetter.isValidCharacter {
            foundWordStart = true
          } else {
            column += 1
          }
        }
      }
    }

    return (column: column, line: startLine, currentScope)
  }
}
