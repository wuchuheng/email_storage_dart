import 'package:test/test.dart';

import 'dart:convert';

// Class to represent an IMAP folder
class ImapFolder {
  final String name;
  final List<String> attributes;
  final String delimiter;

  ImapFolder({
    required this.name,
    required this.attributes,
    required this.delimiter,
  });

  @override
  String toString() {
    return 'ImapFolder(name: $name, attributes: $attributes, delimiter: $delimiter)';
  }
}

// Function to parse the IMAP response and return a list of folders
List<ImapFolder> parseImapFolders(String response) {
  final folderList = <ImapFolder>[];
  final lines = LineSplitter.split(response);

  for (var line in lines) {
    if (line.startsWith('* LIST')) {
      // Extract attributes
      final attributesMatch = RegExp(r'\(([^)]*)\)').firstMatch(line);
      final List<String> attributes = attributesMatch != null
          ? attributesMatch.group(1)?.split(' ') ?? []
          : [];

      // Extract delimiter and folder name
      final remainingPart = line.split(') ')[1];
      final parts = remainingPart.split(' "');
      final delimiter = parts[0].replaceAll('"', '');
      final name = parts[1].replaceAll('"', '');

      // Create and add the folder to the list
      folderList.add(ImapFolder(
        name: name,
        attributes: attributes,
        delimiter: delimiter,
      ));
    }
  }

  return folderList;
}

void main() {
  group('Imap4CapabilityCheckerAbstract', () {
    test("Test", () {
      // Example IMAP server response
      const imapResponse = '''
* LIST () "/" "Archive"
* LIST () "/" "Junk"
* LIST () "/" "tmp/.history/index"
* LIST (\\Noinferiors) "/" "INBOX"
* LIST () "/" "tmp/.history/actions"
* LIST () "/" "tmp"
* LIST () "/" "tmp/.history"
* LIST (\\Trash) "/" "Deleted Messages"
* LIST (\\Sent) "/" "Sent Messages"
* LIST () "/" "Drafts"
L1 OK LIST completed (took 1 ms)
  ''';

      // Parse the IMAP folders from the response
      final folders = parseImapFolders(imapResponse);

      // Print the folders
      for (var folder in folders) {
        print(folder);
      }
    });
  });
}
