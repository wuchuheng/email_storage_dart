import 'package:path/path.dart';

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
String convertPathToEmailPath({required String path, required String prefix}) {
  if (path.substring(0, 1) == '/') {
    path = path.substring(1);
  }
  path = join(prefix, path).toString();
  _specialCharacterMapEscapeCharacter.forEach((key, value) {
    path = path.replaceAll(key, value);
  });

  return path;
}

String convertEmailPathToPath({required String path, required String prefix}) {
  _escapeCharacterMapSpecialCharacter.forEach((key, value) {
    path = path.replaceAll(key, value);
  });
  path = path.substring(prefix.length);
  return path;
}
