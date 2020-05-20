import Foundation
import XcodeKit

class JoinLineCommand : NSObject, XCSourceEditorCommand {
  let wordController = WordController()

  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    var sourceTextRanges = [XCSourceTextRange]()
    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let lines = invocation.buffer.lines as? [String] else { continue }

      selection.start.column = lines[selection.start.line].count - 1
      selection.end.column = selection.start.column
      selection.end.line = selection.start.line
      sourceTextRanges.append(selection)

      var startColumn = max(selection.start.column,0)
      let lineCount = lines.count
      var startLine = min(selection.start.line, lineCount - 1)
      var endLine = min(selection.end.line, lineCount - 1)
      let currentScope = lines[startLine...endLine].joined()

      startColumn = min(selection.start.column, max(currentScope.count-1,0))

      let ctx = wordController.findNextNonWhitespace(startLine: &startLine,
                                                     endLine: &endLine, column: &startColumn,
                                                     contents: lines)
      startColumn = ctx.column
      startLine = ctx.line

      let newSelection = XCSourceTextRange(start: XCSourceTextPosition(line: selection.start.line, column: selection.start.column),
                                           end: XCSourceTextPosition(line: ctx.line, column: ctx.column))
      var previousIndex: Int?
      for case let selection as XCSourceTextRange in invocation.buffer.selections {
        for index in (selection.start.line...newSelection.end.line).reversed() {
          guard var line = invocation.buffer.lines[index] as? String else {
            continue
          }

          if index == selection.start.line, let previousIndex = previousIndex,
            let previousLine = invocation.buffer.lines[previousIndex] as? String {
            line = String(line.dropLast())
            line.append(previousLine)
            invocation.buffer.lines.removeObject(at: previousIndex)
            invocation.buffer.lines[index] = line
          } else {
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if line.isEmpty {
              invocation.buffer.lines.removeObject(at: index)
            } else {
              invocation.buffer.lines[index] = line
            }
          }

          previousIndex = index
        }
      }

      sourceTextRanges.append(selection)
    }

    invocation.buffer.selections.setArray(sourceTextRanges)
  }
}

