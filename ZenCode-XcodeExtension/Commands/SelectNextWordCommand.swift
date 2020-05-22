import Foundation
import XcodeKit

class SelectNextWordCommand: NSObject, XCSourceEditorCommand {
  let wordController = SelectionController()

  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    var sourceTextRanges = [XCSourceTextRange]()
    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let lines = invocation.buffer.lines as? [String] else { continue }

      let ctx = runCommand(selection, lines: lines)
      let newSelection = XCSourceTextRange(start: XCSourceTextPosition(line: ctx.startLine, column: ctx.startColumn),
                                           end: XCSourceTextPosition(line: ctx.startLine, column: ctx.endColumn))

      sourceTextRanges.append(newSelection)
    }
    invocation.buffer.selections.setArray(sourceTextRanges)
  }

  func runCommand(_ selection: XCSourceTextRange, lines: [String]) -> (startLine: Int, startColumn: Int, endColumn: Int) {
    var startColumn = max(selection.start.column,0)
    var endColumn = max(selection.end.column,0)
    let lineCount = lines.count
    var startLine = min(selection.start.line, lineCount - 1)
    var endLine = min(selection.end.line, lineCount - 1)
    let currentScope = lines[startLine...endLine].joined()
    let startWord: Character = currentScope[min(selection.start.column, max(currentScope.count-1,0))]

    startColumn = min(selection.start.column, max(currentScope.count-1,0))
    endColumn = min(selection.end.column, max(currentScope.count-1,0))

    var shouldFindNextWord = !startWord.isValidCharacter
    if startWord.isValidCharacter {
      if startColumn > 0 {
        selectWord(in: currentScope, startColumn: &startColumn, endColumn: &endColumn)
      }
      if startColumn == selection.start.column && endColumn == selection.end.column {
        startColumn = endColumn
        shouldFindNextWord = true
      }
    }

    if shouldFindNextWord {
      let ctx = wordController.findNextWord(startLine: &startLine,
                             endLine: &endLine, column: &startColumn,
                             contents: lines)
      startColumn = ctx.column
      endColumn = ctx.column
      startLine = ctx.line

      selectWord(in: ctx.currentScope, startColumn: &startColumn, endColumn: &endColumn)
    }

    return (startLine: startLine, startColumn: startColumn, endColumn: endColumn)
  }

  func selectWord(in currentScope: String, startColumn: inout Int, endColumn: inout Int) {
    wordController.findWordBoundaries(start: &startColumn, modifier: { $0 -= 1 }, scope: currentScope)
    startColumn += 1
    endColumn = startColumn
    wordController.findWordBoundaries(start: &endColumn, modifier: { $0 += 1 }, scope: currentScope)
  }
}
