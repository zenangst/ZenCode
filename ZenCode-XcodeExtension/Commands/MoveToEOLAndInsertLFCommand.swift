import Foundation
import XcodeKit

class MoveToEOLAndInsertLFCommand : NSObject, XCSourceEditorCommand {
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    var sourceTextRanges = [XCSourceTextRange]()
    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let lines = invocation.buffer.lines as? [String] else { continue }

      let lineCount = lines.count
      let startLine = min(selection.start.line, lineCount - 1)
      let endLine = min(selection.end.line, lineCount - 1)
      let currentScope = lines[startLine...endLine].joined()

      var padding = ""
      for character in currentScope {
        if !character.isWhitespace {
          break
        }

        padding += String(character)
      }

      invocation.buffer.lines.insert("\(padding)", at: selection.end.line + 1)
      selection.start.line += 1
      selection.start.column = padding.count
      selection.end = selection.start

      sourceTextRanges.append(XCSourceTextRange(start: selection.start, end: selection.end))
    }
    invocation.buffer.selections.setArray(sourceTextRanges)
  }
}
