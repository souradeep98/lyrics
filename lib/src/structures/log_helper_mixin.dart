part of '../structures.dart';

class LogHelper {
  const LogHelper();

  void logER(
    Object? message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (shouldLog) {
      log(
        message.toString(),
        time: time ?? DateTime.now(),
        sequenceNumber: sequenceNumber,
        level: level,
        name: name ?? _getName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String get _getName {
    if (this is State) {
      return (this as State).widget.runtimeType.toString();
    } else {
      // ignore: no_runtimetype_tostring
      return runtimeType.toString();
    }
  }

  bool get shouldLog => kDebugMode;
}

mixin LogHelperMixin {
  String? _nameCache;

  void logER(
    Object? message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (shouldLog) {
      log(
        message.toString(),
        time: time ?? DateTime.now(),
        sequenceNumber: sequenceNumber,
        level: level,
        name: name ?? (_nameCache ??= _getName),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String get _getName {
    if (this is State) {
      return (this as State).widget.runtimeType.toString();
    } else {
      return runtimeType.toString();
    }
  }

  final bool shouldLog = kDebugMode;
}
