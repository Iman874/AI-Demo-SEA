import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class _FileOutput extends LogOutput {
  final IOSink _sink;
  _FileOutput(this._sink);

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      _sink.writeln(line);
    }
    _sink.flush();
  }
}

class _MultiOutput extends LogOutput {
  final List<LogOutput> _outputs;
  _MultiOutput(this._outputs);

  @override
  void output(OutputEvent event) {
    for (final out in _outputs) {
      out.output(event);
    }
  }
}

class AppLogger {
  static Logger? _logger;
  static IOSink? _sink;
  static String? _currentLogPath;

  /// Initialize logger and open (or create) `sea_log.log` in app documents dir.
  static Future<void> init() async {
    // If running on web, dart:io and path_provider are not available.
    if (kIsWeb) {
      _currentLogPath = null;
      _logger = Logger();
      //print('AppLogger running on web: using console-only logger');
      return;
    }

    try {
      // Try to write to project-relative lib/log/sea_app.log first (helps during dev)
      final projectPath = Directory.current.path;
      final projectFile = File('${projectPath}${Platform.pathSeparator}lib${Platform.pathSeparator}log${Platform.pathSeparator}sea_app.log');
      if (!await projectFile.exists()) {
        await projectFile.parent.create(recursive: true);
        await projectFile.create();
      }
      _sink = projectFile.openWrite(mode: FileMode.append);
      _currentLogPath = projectFile.path;
      // write to both console and file so developer sees logs immediately
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: false,
          printEmojis: false,
          printTime: true,
        ),
        output: _MultiOutput([ConsoleOutput(), _FileOutput(_sink!)]),
      );
      // echo chosen path to console so developer can verify
      //print('AppLogger initialized, log file: ${projectFile.path}');
      i('AppLogger initialized, log file: ${projectFile.path}');
      return;
    } catch (e) {
      // ignore and try fallback
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}log${Platform.pathSeparator}sea_log.log');
      // ensure file exists
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      _sink = file.openWrite(mode: FileMode.append);
      _currentLogPath = file.path;
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: false,
          printEmojis: false,
          printTime: true,
        ),
        output: _MultiOutput([ConsoleOutput(), _FileOutput(_sink!)]),
      );
      //print('AppLogger initialized (fallback), log file: ${file.path}');
      i('AppLogger initialized (fallback), log file: ${file.path}');
    // ignore: unused_catch_stack
    } catch (e2, st2) {
      // Last resort: use console logger so app keeps running
      _logger = Logger();
  //print('AppLogger init failed, using console logger. Error: $e2');
  //print(st2);
    }
  }

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.d(_format(message, error, stackTrace));
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.i(_format(message, error, stackTrace));
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.w(_format(message, error, stackTrace));
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(_format(message, error, stackTrace));
  }

  static void v(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.v(_format(message, error, stackTrace));
  }

  static String _format(String message, dynamic error, StackTrace? stackTrace) {
    final buffer = StringBuffer();
    buffer.write(message);
    if (error != null) {
      buffer.write(' | error: ${error.toString()}');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }

  /// Close file sink when app is terminating (optional)
  static Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
  }

  /// Returns the path of the current log file (if initialized)
  static String? get currentLogPath => _currentLogPath;
}
