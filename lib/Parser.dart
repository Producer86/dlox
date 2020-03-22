import 'package:dlox/Expr.dart';
import 'package:dlox/Lox.dart' as lox;
import 'package:dlox/Token.dart';
import 'package:dlox/TokenType.dart';

/*
expression -> equality ;
equality -> comparison ( ( "!=" | "==" ) comparison )* ;
comparison -> addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
addition -> multiplication ( ( "+" | "-" )  multiplication )* ;
multiplication -> unary ( ( "*" | "/" ) unary )* ;
unary -> ( "!" | "-" ) unary | primary ;
primary -> NUMBER | STRING | "false" | "true" | "nil" | "(" expression ")" ;
*/

class Parser {
  Parser(this._tokens);

  final List<Token> _tokens;
  int _current = 0;

  Expr parse() {
    try {
      return _expression();
    } on ParseError {
      return null;
    }
  }

  Expr _expression() {
    return _equality();
  }

  Expr _equality() {
    var expr = _comparison();

    while (_match([
      TokenType.BangEqual,
      TokenType.EqualEqual,
    ])) {
      final op = _previous();
      final right = _comparison();
      expr = Binary(expr, op, right);
    }

    return expr;
  }

  Expr _comparison() {
    var expr = _addition();

    while (_match([
      TokenType.Greater,
      TokenType.GreaterEqual,
      TokenType.Less,
      TokenType.LessEqual
    ])) {
      final op = _previous();
      final right = _addition();
      expr = Binary(expr, op, right);
    }

    return expr;
  }

  Expr _addition() {
    var expr = _multiplication();

    while (_match([
      TokenType.Minus,
      TokenType.Plus,
    ])) {
      final op = _previous();
      final right = _multiplication();
      expr = Binary(expr, op, right);
    }

    return expr;
  }

  Expr _multiplication() {
    var expr = _unary();

    while (_match([
      TokenType.Slash,
      TokenType.Star,
    ])) {
      final op = _previous();
      final right = _unary();
      expr = Binary(expr, op, right);
    }

    return expr;
  }

  Expr _unary() {
    if (_match([
      TokenType.Bang,
      TokenType.Minus,
    ])) {
      final op = _previous();
      final right = _unary();
      return Unary(op, right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.False])) {
      return Literal(false);
    }
    if (_match([TokenType.True])) {
      return Literal(true);
    }
    if (_match([TokenType.Nil])) {
      return Literal(null);
    }
    if (_match([TokenType.Number, TokenType.String])) {
      return Literal(_previous().literal);
    }
    if (_match([TokenType.LeftParen])) {
      final expr = _expression();
      _consume(TokenType.RightParen, 'Expected ")" after expression.');
      return Grouping(expr);
    }
    throw _error(_peek(), 'Expected expression.');
  }

  bool _match(List<TokenType> types) {
    for (var type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) {
      return _advance();
    }
    throw _error(_peek(), message);
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) {
      return false;
    }
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) {
      _current++;
    }
    return _previous();
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.Eof;
  }

  Token _peek() {
    return _tokens[_current];
  }

  Token _previous() {
    return _tokens[_current - 1];
  }

  ParseError _error(Token token, String message) {
    lox.error_token(token, message);
    return ParseError(message);
  }

  // we use Dart's callstack to keep track of the parser's state
  // when we encounter a syntax error we want to reset the state
  // to a safe checkpoint to avoid cascading errors.
  // for this we choose statement boundaries.
  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.Semicolon) return;

      switch (_peek().type) {
        case TokenType.Class:
        case TokenType.Fun:
        case TokenType.Var:
        case TokenType.For:
        case TokenType.If:
        case TokenType.While:
        case TokenType.Print:
        case TokenType.Return:
          return;
        default:
          break;
      }
      _advance();
    }
  }
}

class ParseError implements Exception {
  final String msg;
  const ParseError([this.msg]);
  @override
  String toString() {
    return msg ?? 'ParserException';
  }
}
