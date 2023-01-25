const Map<String, String> _specialCharacterMapEscapeCharacter = {
  '~': '-tildeAccent-',
  '!': '-exclamationMark-',
  '#': '-number-',
  '\$': '-dollar-',
  '%': '-percent-',
  '^': '-spacingCircumflexAccent-',
  '&': '-ampersand-',
  '*': '-asterisk-',
  '(': '-leftParenthesis-',
  ')': '-rightParenthesis-',
  '=': '-equal-',
  '+': '-plus-',
  '|': '-verticalBar-',
  '\\': '-backslash-',
  '\'': '-singleQuote-',
  '[': '-leftSquareBracket-',
  ']': '-rightSquareBracket-',
  '{': '-leftCurlyBracket-',
  '}': '-rightCurlyBracket-',
  ';': '-semicolon-',
  ':': '-colon-',
  '"': '_doubleQuotationMark-',
  ',': '-comma-',
  '?': '-questionMark-',
  '/': '_',
  '<': '-lessThan-',
  '>': '-greaterThan-',
  ' ': '-space-'
};

const Map<String, String> _escapeCharacterMapSpecialCharacter = {
  '-tildeAccent-': '~',
  '-exclamationMark-': '!',
  '-number-': '#',
  '-dollar-': '\$',
  '-percent-': '%',
  '-spacingCircumflexAccent-': '^',
  '-ampersand-': '&',
  '-asterisk-': '*',
  '-leftParenthesis-': '(',
  '-rightParenthesis-': ')',
  '-equal-': '=',
  '-plus-': '+',
  '-verticalBar-': '|',
  '-backslash-': '\\',
  '-singleQuote-': '\'',
  '-leftSquareBracket-': '[',
  '-rightSquareBracket-': ']',
  '-leftCurlyBracket-': '{',
  '-rightCurlyBracket-': '}',
  '-semicolon-': ';',
  '-colon-': ':',
  '_doubleQuotationMark-': '"',
  '-comma-': ',',
  '-questionMark-': '?',
  '_': '/',
  '-lessThan-': '<',
  '-greaterThan-': '>',
  '-space-': ' '
};

/// To convert the path to email path that the email path not allow to includes some characters likes :
///
String convertPathToEmailPath(String path) {
  _specialCharacterMapEscapeCharacter.forEach((key, value) {
    path = path.replaceAll(key, value);
  });

  return path;
}

String convertEmailPathToPath(String path) {
  _escapeCharacterMapSpecialCharacter.forEach((key, value) {
    path = path.replaceAll(key, value);
  });

  return path;
}
