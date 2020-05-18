import Foundation
import XcodeKit

class SelectNextWordCommand: NSObject, XCSourceEditorCommand {
  let wordController = WordController()

  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    var sourceTextRanges = [XCSourceTextRange]()
    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let stringArray = invocation.buffer.lines as? [String] else { continue }

      var startColumn = max(selection.start.column,0)
      var endColumn = max(selection.end.column,0)
      let lineCount = stringArray.count
      var startLine = min(selection.start.line, lineCount - 1)
      var endLine = min(selection.end.line, lineCount - 1)
      let currentScope = stringArray[startLine...endLine].joined()
      let startWord: Character = currentScope[max(selection.start.column, 0)]

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
                               contents: stringArray)
        startColumn = ctx.column
        endColumn = ctx.column
        startLine = ctx.line

        selectWord(in: ctx.currentScope, startColumn: &startColumn, endColumn: &endColumn)
      }

      let newSelection = XCSourceTextRange(start: XCSourceTextPosition(line: startLine, column: startColumn),
                                           end: XCSourceTextPosition(line: startLine, column: endColumn))

      sourceTextRanges.append(newSelection)
    }
    invocation.buffer.selections.setArray(sourceTextRanges)
  }

  func selectWord(in currentScope: String, startColumn: inout Int, endColumn: inout Int) {
    wordController.findWordBoundaries(start: &startColumn, modifier: { $0 -= 1 }, scope: currentScope)
    startColumn += 1
    endColumn = startColumn
    wordController.findWordBoundaries(start: &endColumn, modifier: { $0 += 1 }, scope: currentScope)
  }
}
