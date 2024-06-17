import 'dart:developer';

class DatabaseRunningException implements Exception {
  final String message;
  DatabaseRunningException([this.message = 'Database is already running.']);

  @override
  String toString() {
    final logMessage = 'DatabaseRunningException: $message';
    log(logMessage);
    return logMessage;
  }
}

class UnableToGetDocumentsDirectory implements Exception {
  final String message;
  UnableToGetDocumentsDirectory(
      [this.message = 'Unable to get documents directory.']);

  @override
  String toString() {
    final logMessage = 'UnableToGetDocumentsDirectory: $message';
    log(logMessage);
    return logMessage;
  }
}

class DatabaseNotRunningException implements Exception {
  final String message;
  DatabaseNotRunningException([this.message = 'Database is not running.']);

  @override
  String toString() {
    final logMessage = 'DatabaseNotRunningException: $message';
    log(logMessage);
    return logMessage;
  }
}

class DatabaseIsNotOpen implements Exception {
  final String message;
  DatabaseIsNotOpen([this.message = 'Database is not open.']);

  @override
  String toString() {
    final logMessage = 'DatabaseIsNotOpen: $message';
    log(logMessage);
    return logMessage;
  }
}

class UserAlreadyExists implements Exception {
  final String message;
  UserAlreadyExists([this.message = 'User already exists.']);

  @override
  String toString() {
    final logMessage = 'UserAlreadyExists: $message';
    log(logMessage);
    return logMessage;
  }
}

class UserDoesNotExist implements Exception {
  final String message;
  UserDoesNotExist([this.message = 'User does not exist.']);

  @override
  String toString() {
    final logMessage = 'UserDoesNotExist: $message';
    log(logMessage);
    return logMessage;
  }
}

class UserAccessDenied implements Exception {
  final String message;
  UserAccessDenied([this.message = 'User access denied.']);

  @override
  String toString() {
    final logMessage = 'UserAccessDenied: $message';
    log(logMessage);
    return logMessage;
  }
}

class UnknownSignalType implements Exception {
  final String message;
  UnknownSignalType([this.message = 'Signal type unknown']);

  @override
  String toString() {
    final logMessage = 'UnknownSignalType: $message';
    log(logMessage);
    return logMessage;
  }
}

class SignalDoesNotExist implements Exception {
  final String message;
  SignalDoesNotExist([this.message = 'Signal does not exist']);

  @override
  String toString() {
    final logMessage = 'SignalDoesNotExist: $message';
    log(logMessage);
    return logMessage;
  }
}
