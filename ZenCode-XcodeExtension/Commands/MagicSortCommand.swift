import Cocoa
import Foundation
import XcodeKit

class MagicSortCommand: NSObject, XCSourceEditorCommand {
  let selectionController = SelectionController()


  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    for case let selection as XCSourceTextRange in invocation.buffer.selections {
      guard let lines = invocation.buffer.lines as? [String] else { continue }

      let lineCount = lines.count
      let startLine = min(selection.start.line, lineCount - 1)
      let endLine = min(selection.end.line, lineCount - 1)
      let currentLines = Array(lines[startLine...endLine])

      let startLineContents = lines[startLine]
      let endLineContents = lines[endLine]
      let startCharacter: Character = startLineContents[selection.start.column]
      let endCharacter: Character = endLineContents[max(selection.end.column-1, 0)]
      let delimiter = Delimiter(rawValue: String(startCharacter))
      let delimiterMatch = delimiter?.counterDelimiter == String(endCharacter)

      if let delimiter = delimiter, delimiterMatch {
        if currentLines.count > 1 {
          delimiterSortMultipleLines(currentLines, selection, delimiter, invocation)
        } else {
          let currentLine = String(startLineContents.dropLast())
          let currentSelection = String(startLineContents[selection.start.column+1..<selection.end.column-1])
          delimiterSortSingleLine(currentLine, currentSelection, selection, delimiter, invocation)
        }
      } else {
        sortLines(startLine: startLine, endLine: endLine,
                  lines: currentLines, buffer: invocation.buffer)
      }
    }
  }

  fileprivate func delimiterSortSingleLine(_ currentLine: String,
                                           _ currentSelection: String,
                                           _ selection: XCSourceTextRange,
                                           _ delimiter: Delimiter,
                                           _ invocation: XCSourceEditorCommandInvocation) {
    let collection = collectDelimiters(currentLine)
    if let matchedDelimiter = collection.sorted(by: { $0.1 > $1.1 }).first?.key {
      let sortedContent = sortContent(currentSelection, with: matchedDelimiter)
      let result = "\(delimiter.rawValue)\(sortedContent)\(delimiter.counterDelimiter)"
      var line = currentLine
      let startIndex = line.index(line.startIndex, offsetBy: selection.start.column)
      let endIndex = line.index(line.startIndex, offsetBy: selection.end.column)
      line.replaceSubrange(startIndex..<endIndex, with: result)
      invocation.buffer.lines[selection.start.line] = line
    }
  }

  fileprivate func delimiterSortMultipleLines(_ currentLines: [String], _ selection: XCSourceTextRange, _ delimiter: Delimiter, _ invocation: XCSourceEditorCommandInvocation) {
    var selectedContent: String = ""
    var padding: Int = 0

    for (offset, line) in currentLines.enumerated() {
      if offset == 0 {
        selectedContent.append(line[selection.start.column+1..<line.count])
      } else if offset == currentLines.count - 1 {
        selectedContent.append(line[0..<selection.end.column-1])
      } else {
        padding = line.count - line.trimmingCharacters(in: .whitespaces).count
        selectedContent.append(line)
      }
    }

    let collection = collectDelimiters(selectedContent)

    if let matchedDelimiter = collection.sorted(by: { $0.1 > $1.1 }).first?.key {
      let newLines = sortContent(selectedContent, with: matchedDelimiter).split(separator: Character(matchedDelimiter.rawValue))
      var offset: Int = newLines.count - 1
      for index in (selection.start.line...selection.end.line).reversed() {
        defer { offset -= 1 }
        guard let line = invocation.buffer.lines[index] as? String else {
          continue
        }

        let paddedLine = "".padding(toLength: padding, withPad: " ", startingAt: 0)
        let trimmedLine = newLines[offset].trimmingCharacters(in: .whitespacesAndNewlines)

        if index == selection.start.line {
          let linePrefix = line[line.startIndex...line.index(line.startIndex, offsetBy: selection.start.column - 1)]
          let newLine = "\(linePrefix)\(delimiter.rawValue)\(trimmedLine)\(matchedDelimiter.rawValue)"
          invocation.buffer.lines[index] = newLine
        } else if index == selection.end.line {
          let lineSuffix = String(line[line.index(line.startIndex, offsetBy: selection.end.column)..<line.endIndex])
          let newLine = "\(paddedLine)\(trimmedLine)\(delimiter.counterDelimiter)\(lineSuffix)".trimmingCharacters(in: .newlines)
          invocation.buffer.lines[index] = newLine
          selection.end.column = newLine.count - lineSuffix.count + 1
        } else {
          let newLine = "\(paddedLine)\(trimmedLine)\(matchedDelimiter.rawValue)"
          invocation.buffer.lines[index] = newLine
        }
      }
    }
  }

  fileprivate func sortContent(_ content: String, with delimiter: Delimiter) -> String {
    let lines = content
      .split(separator: Character(delimiter.rawValue))
      .compactMap({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    var sorted = lines.sorted(by: <)
    if lines == sorted {
      sorted = lines.sorted(by: >)
    }

    var newString = String()
    for (offset, line) in sorted.enumerated() {
      let suffix: String = offset < sorted.count - 1
        ? "\(delimiter.rawValue) "
        : ""
      newString.append("\(line)\(suffix)")
    }

    return newString
  }

  fileprivate func collectDelimiters(_ content: String) -> [Delimiter: Int] {
    var collection = [Delimiter: Int]()
    for char in content {
      if let delimiter = Delimiter.init(rawValue: String(char)) {
        let currentCount = collection[delimiter] ?? 0
        collection[delimiter] = currentCount + 1
      }
    }
    return collection
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
