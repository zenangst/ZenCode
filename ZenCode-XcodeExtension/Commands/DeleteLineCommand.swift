import Foundation
import XcodeKit

class DeleteLineCommand : NSObject, XCSourceEditorCommand {
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

//    var padding = 0
//    for index in selection.start.line...selection.end.line {
//      invocation.buffer.lines.insert(invocation.buffer.lines[index + padding], at: selection.start.line)
//      padding = padding + 1
//    }
  }
}
