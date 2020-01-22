import 'dart:io';
import 'package:dlox/Lox.dart' as lox;

void main(List<String> arguments) {
  if (arguments.length > 1) {
    print('Usage: dlox [script]');
    exit(64);
  } else if (arguments.length == 1) {
    lox.runFile(arguments[0]);
  } else {
    lox.runPrompt();
  }
}
