import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/folder.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

import '../dto/request/request.dart';

class ListCommand implements CommandAbstract<List<Folder>> {
  final String name;
  final String pattern;
  final OnImapWriteType _onWrite;
  late Response<List<String>> _response;

  ListCommand({
    this.name = "",
    this.pattern = "",
    required OnImapWriteType onWrite,
  }) : _onWrite = onWrite;

  @override
  Future<Response<List<Folder>>> execute() async {
    // 1. Create the request of the command `LIST`
    final request = Request(
      command: Command.LIST,
      arguments: ['"$name"', '"$pattern"'],
    );

    // 2. Write the request to the server
    _response = await _onWrite(request: request);

    // 3. return this.
    return parse();
  }

  List<Folder> _parseImapFolders(List<String> lines, {String delimiter = "/"}) {
    final folderList = <Folder>[];

    for (final String line in lines) {
      if (line.startsWith('LIST')) {
        final attributesMatch = RegExp(r'\(([^)]*)\)').firstMatch(line);
        final List<String> attributes = attributesMatch != null
            ? attributesMatch.group(1)?.split(' ') ?? []
            : [];

        final remainingPart = line.split(') ')[1];
        final parts = remainingPart.split(' "$delimiter"');
        final name = parts.last.replaceAll('"', '');

        folderList.add(Folder(
          name: name,
          attributes: attributes,
          delimiter: delimiter,
        ));
      }
    }

    return folderList;
  }

  Response<List<Folder>> parse() {
    final List<Folder> folders = _parseImapFolders(
      _response.data,
      delimiter: "/",
    );
    Response<List<Folder>> result = Response(
      status: _response.status,
      data: folders,
      tag: _response.tag,
      message: _response.message,
    );

    return result;
  }
}
