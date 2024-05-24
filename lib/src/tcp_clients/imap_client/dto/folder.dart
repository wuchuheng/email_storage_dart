class Folder {
  final String name;
  final List<String> attributes;
  final String delimiter;

  Folder({
    required this.name,
    required this.attributes,
    required this.delimiter,
  });

  @override
  String toString() {
    return 'ImapFolder(name: $name, attributes: $attributes, delimiter: $delimiter)';
  }
}
