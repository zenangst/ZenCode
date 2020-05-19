import Foundation
import XcodeKit

class SmartSortCommand: NSObject, XCSourceEditorCommand {
  let wordController = WordController()

  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let stringArray = invocation.buffer.lines as? [String] else { continue }

      var startColumn = max(selection.start.column,0)
      var endColumn = max(selection.end.column,0)
      let lineCount = stringArray.count
      var startLine = min(selection.start.line, lineCount - 1)
      var endLine = min(selection.end.line, lineCount - 1)
      let currentLines = Array(stringArray[startLine...endLine])
      let currentScope = currentLines.joined()

      if currentScope.contains("import") {
        var result: [String] = currentLines.sorted { $0 > $1 }
        if result == currentLines {
          result = result.sorted { $0 < $1 }
        }

      }
    }
  }
}
