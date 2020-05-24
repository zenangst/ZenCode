import XcodeKit

class SmartSortCommand: NSObject, XCSourceEditorCommand {
  let selectionController = SelectionController()

  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let lines = invocation.buffer.lines as? [String] else { continue }

      let lineCount = lines.count
      let startLine = min(selection.start.line, lineCount - 1)
      let endLine = min(selection.end.line, lineCount - 1)
      let currentLines = Array(lines[startLine...endLine])

      if currentLines.count > 1 {
        let startLineContents = lines[startLine]
        let endLineContents = lines[endLine]
        let startCharacter: Character = startLineContents[selection.start.column]
        let endCharacter: Character = endLineContents[selection.end.column-1]

        if let delimiter = Delimiter.init(rawValue: String(startCharacter)),
          delimiter.counterDelimiter == String(endCharacter) {

          var selectedContent: String = ""
          for (offset, line) in currentLines.enumerated() {
            if offset == 0 {
              selectedContent.append(line[selection.start.column+1..<line.count])
            } else if offset == currentLines.count - 1 {
              selectedContent.append(line[0..<selection.end.column-1])
            } else {
              selectedContent.append(line)
            }
          }

          var collection = [Delimiter: Int]()
          for char in selectedContent {
            if let delimiter = Delimiter.init(rawValue: String(char)) {
              let currentCount = collection[delimiter] ?? 0
              collection[delimiter] = currentCount + 1
            }
          }

          if let matchedDelimiter = collection.sorted(by: { $0.1 > $1.1 }).first?.key {
            let lines = selectedContent
              .split(separator: Character(matchedDelimiter.rawValue))
              .compactMap({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            var sorted = lines.sorted(by: <)
            if lines == sorted {
              sorted = lines.sorted(by: >)
            }

            var newString = String()
            for (offset, line) in sorted.enumerated() {
              let suffix: String = offset < sorted.count - 1
                ? "\(matchedDelimiter.rawValue) "
                : ""
              newString.append("\(line)\(suffix)")
            }

            let result = "\(delimiter.rawValue)\(newString)\(delimiter.counterDelimiter)"
            var lineSuffix: String = ""
            for index in (selection.start.line...selection.end.line).reversed() {
              guard let line = invocation.buffer.lines[index] as? String else {
                continue
              }

              if index == selection.start.line {
                let linePrefix = line[line.startIndex...line.index(line.startIndex, offsetBy: selection.start.column - 1)]
                invocation.buffer.lines[index] = "\(linePrefix)\(result)\(lineSuffix)"
              } else if index == selection.end.line {
                lineSuffix = String(line[line.index(line.startIndex, offsetBy: selection.end.column)..<line.endIndex])
                invocation.buffer.lines.removeObject(at: index)
              } else {
                invocation.buffer.lines.removeObject(at: index)
              }
            }
          }
        } else {
          sortLines(startLine: startLine, endLine: endLine,
                    lines: currentLines, buffer: invocation.buffer)
        }
      }
    }
  }

  func sortLines(startLine: Int, endLine: Int,
                 lines: [String],
                 buffer: XCSourceTextBuffer) {
    var result: [String] = lines.sorted { $0 < $1 }
    if result == lines {
      result = result.sorted { $0 > $1 }
    }

    for (offset, element) in result.enumerated() {
      buffer.lines[offset + startLine] = element
    }
  }
}
