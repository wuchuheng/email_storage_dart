/// The file used to convert enum channel name to string from enu or convert string to enum channel name.
T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere((v) => v.toString().split('.')[1] == value);
}

enum ChannelName { connect }
