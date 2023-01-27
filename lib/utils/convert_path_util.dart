import 'package:path/path.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';

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

String convertPathToEmailStoragePath({required String path, required EmailAccount emailAccount}) {
  path = path == '/' ? '' : path;
  path = join(emailAccount.storageName, 'storage', path).toString();

  return path;
}

String convertEmailPathToPath(String path) {
  _escapeCharacterMapSpecialCharacter.forEach((key, value) {
    path = path.replaceAll(key, value);
  });

  return path;
}
