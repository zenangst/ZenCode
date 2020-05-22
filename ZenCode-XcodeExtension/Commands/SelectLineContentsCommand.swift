import Foundation
import XcodeKit

class SelectLineContentsCommand : NSObject, XCSourceEditorCommand {
  let wordController = SelectionController()

  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    var sourceTextRanges = [XCSourceTextRange]()
    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let lines = invocation.buffer.lines as? [String] else { continue }

      let ctx = runCommand(selection, lines: lines)

      let newSelection = XCSourceTextRange(start: XCSourceTextPosition(line: ctx.startLine, column: ctx.startColumn),
                                           end: XCSourceTextPosition(line: ctx.endLine, column: ctx.endColumn))

      sourceTextRanges.append(newSelection)
    }
    invocation.buffer.selections.setArray(sourceTextRanges)
  }

  func runCommand(_ selection: XCSourceTextRange, lines: [String]) -> (startLine: Int, startColumn: Int, endLine: Int, endColumn: Int) {
    let lineCount = lines.count
    let startLine = min(selection.start.line, lineCount - 1)
    var startColumn = 0
    let endLine = min(selection.end.line, lineCount - 1)
    var endColumn = lines[endLine].count

    findBoundaries(start: &startColumn, modifier: { $0 += 1 }, scope: lines[startLine])
    findBoundaries(start: &endColumn, modifier: { $0 -= 1 }, scope: lines[endLine])

    return (startLine: startLine, startColumn: startColumn, endLine: endLine, endColumn: endColumn)
  }

  func findBoundaries(start: inout Int, modifier: (inout Int) -> Void, scope: String) {
    var foundWordBondary = false
    while !foundWordBondary {
      if start >= scope.count {
        foundWordBondary = true
        break
      } else {
        let character: Character = scope[start]
        if !character.isWhitespace {
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
}
