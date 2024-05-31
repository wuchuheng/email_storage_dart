import 'dart:convert';

import 'package:test/test.dart';

String decodeQuotedPrintable(String input) {
  final RegExp exp = RegExp(r'=[0-9A-Fa-f]{2}');
  final bytes = <int>[];

  input.replaceAllMapped(exp, (Match match) {
    final String hex = match.group(0)!.substring(1);
    final int charCode = int.parse(hex, radix: 16);
    bytes.add(charCode);
    return '';
  }).replaceAll('=\n', ''); // Handle soft line breaks

  return utf8.decode(bytes);
}

void main() {
  group('Imap4CapabilityCheckerAbstract', () {
    test("Test", () {
//       const quotedPrintableText = '''=E6=AD=A4=E9=82=AE=E4=BB=B6=E7=94=B1=E9=98=
// =BF=E9=87=8C=E4=BA=91=E5=8F=91=E9=80=81=EF=BC=8C=E7=94=B1=E7=B3=BB=E7=BB=9F=
// =E8=87=AA=E5=8A=A8=E5=8F=91=E5=87=BA=EF=BC=8C=E8=AF=B7=E5=8B=BF=E7=9B=B4=E6=
// =8E=A5=E5=9B=9E=E5=A4=8D=EF=BC=8C=E8=B0=A2=E8=B0=A2=EF=BC=81''';

      // final decodedText = decodeQuotedPrintable(quotedPrintableText);
      // print(decodedText);
    });
  });
}
