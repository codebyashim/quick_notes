sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class SessionException extends AppException {
  const SessionException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class StorageException extends AppException {
  const StorageException(super.message);
}

class NotesException extends AppException {
  const NotesException(super.message);
}

class FilesException extends AppException {
  const FilesException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
