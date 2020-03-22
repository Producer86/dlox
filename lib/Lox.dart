import 'dart:io';
import 'dart:convert';

import 'package:dlox/AstPrinter.dart';
import 'package:dlox/Interpreter.dart';
import 'package:dlox/Parser.dart';
import 'package:dlox/Scanner.dart';
import 'package:dlox/Token.dart';
import 'package:dlox/TokenType.dart';

final interpreter = Interpreter();

bool hadError = false;
bool hadRuntimeException = false;

void runFile(String path) {
  final source = File(path).readAsStringSync();
  run(source);
  if (hadError) {
    exit(65);
  }
  if (hadRuntimeException) {
    exit(70);
  }
}

void runPrompt() {
  final prompt = stdout.supportsAnsiEscapes ? '[93m>[0m' : '>';
  stdout.write(prompt);
  stdin.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
    run(line);
    hadError = false;
    stdout.write(prompt);
  });
}

void run(String source) {
  final scanner = Scanner(source: source);
  final tokens = scanner.scanTokens();

  final parser = Parser(tokens);
  final expression = parser.parse();
  if (hadError) {
    return;
  }
  print(AstPrinter().print(expression));
  interpreter.interpret(expression);
}

void error_line(int line, String message) {
  report(line, '', message);
}

void error_token(Token token, String message) {
  if (token.type == TokenType.Eof) {
    report(token.line, ' at end', message);
  } else {
    report(token.line, ' at "${token.lexeme}"', message);
  }
}

void report(int line, String where, String message) {
  var errorLabel = stdout.supportsAnsiEscapes ? '[91mError[0m' : 'Error';
  print('[line $line] $errorLabel$where:$message');
  hadError = true;
}

void runtimeException(RuntimeException error) {
  var errorLabel = stdout.supportsAnsiEscapes
      ? '[91mRuntimeException[0m'
      : 'RuntimeException';
  print('[line ${error.token.line}] $errorLabel ${error.message}');
  hadRuntimeException = true;
}
