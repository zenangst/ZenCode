enum Delimiter: String {
  case parenthesis = "("
  case curly = "{"
  case bracket = "["
  case comma = ","
  case semicolon = ";"

  var counterDelimiter: String {
    switch self {
    case .parenthesis:
      return ")"
    case .curly:
      return "}"
    case .bracket:
      return "]"
    case .comma, .semicolon:
      return ""
    }
  }
}
