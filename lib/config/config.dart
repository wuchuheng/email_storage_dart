// The path used to storage data on IMAP server.
const String rootStoragePath = '/storage';
// The path used to save the operation history.
const String rootOperationLogPath = '/operationLog';

// Connection timeout
const connectTimeout = 60;

// The list of path to initialize the path on IMAP server.
const List<String> rootPathList = [
  rootStoragePath,
  rootOperationLogPath,
];
