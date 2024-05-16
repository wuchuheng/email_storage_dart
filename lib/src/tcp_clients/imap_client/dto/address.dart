/// An e-mail address format.
class Address {
  final String name;
  final String address;

  Address({
    this.name = '',
    required this.address,
  }) : assert(address.isNotEmpty);

  /// Get the address in the format: "name <email>".
  String format() {
    if (name.isEmpty) {
      // 1. Return the email address.
      return address;
    } else {
      // 2. Return the formatted address.
      return '$name <$address>';
    }
  }
}
