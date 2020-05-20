import Foundation
import XcodeKit

class SelectWordBelowCommand : NSObject, XCSourceEditorCommand {
  let selectPreviousCommand = SelectPreviousWordCommand()
  let selectNextCommand = SelectNextWordCommand()

  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    var sourceTextRanges = [XCSourceTextRange]()
    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let lines = invocation.buffer.lines as? [String], selection.end.line + 1 < lines.count - 1 else { break }

      let nextLine = lines[selection.start.line - 1]
      let newColumn = nextLine.count > selection.start.column
        ? selection.start.column
        : nextLine.count - 1

      selection.start.column = newColumn
      selection.start.line += 1
      selection.end = selection.start

      invocation.buffer.selections.setArray([
        XCSourceTextRange(start: selection.start, end: selection.end)
      ])

      let ctx = selectNextCommand.runCommand(selection, lines: lines)
      let newSelection = XCSourceTextRange(start: XCSourceTextPosition(line: ctx.startLine, column: ctx.startColumn),
                                           end: XCSourceTextPosition(line: ctx.startLine, column: ctx.endColumn))
      sourceTextRanges.append(newSelection)
    }

    guard !sourceTextRanges.isEmpty else { return }
    invocation.buffer.selections.setArray(sourceTextRanges)
  }
}
