import Foundation
import XcodeKit

class MoveToEOLAndInsertLFCommand : NSObject, XCSourceEditorCommand {
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }
  }
}
