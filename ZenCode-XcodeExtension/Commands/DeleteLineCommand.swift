import Foundation
import XcodeKit

class DeleteLineCommand : NSObject, XCSourceEditorCommand {
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      for index in (selection.start.line...selection.end.line).reversed() {
        invocation.buffer.lines.removeObject(at: index)
      }
    }
  }
}

