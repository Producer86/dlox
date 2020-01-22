import 'dart:io';
import 'dart:convert';

import 'package:dlox/Scanner.dart';

bool hadError = false;

void runFile(String path) {
  final source = File(path).readAsStringSync();
  run(source);
  if (hadError) {
    exit(65);
  }
}

void runPrompt() {
  stdout.write('> ');
  stdin.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
    run(line);
    hadError = false;
    stdout.write('> ');
  });
}

void run(String source) {
  final scanner = Scanner(source: source);
  final tokens = scanner.scanTokens();

  for (var token in tokens) {
    print(token);
  }
}

void error(int line, String message) {
  report(line, '', message);
}

void report(int line, String where, String message) {
  var errorLabel = stdout.supportsAnsiEscapes ? '[91mError[0m' : 'Error';
  print('[line $line] $errorLabel$where:$message');
  hadError = true;
}
