import 'package:dlox/Token.dart';

class ParseError implements Exception {
  final String msg;
  const ParseError([this.msg]);
  @override
  String toString() {
    return msg ?? 'ParserException';
  }
}

class RuntimeException implements Exception {
  final Token token;
  final String message;

  const RuntimeException(this.token, this.message);
}
