import 'package:dlox/Token.dart';
import 'package:dlox/TokenType.dart';
import 'package:dlox/Lox.dart' as lox;

class Scanner {
  final String _source;
  final List<Token> _tokens = <Token>[];
  int _start = 0;
  int _current = 0;
  int _line = 1;
  final _keywords = <String, TokenType>{
    'and': TokenType.And,
    'class': TokenType.Class,
    'else': TokenType.Else,
    'false': TokenType.False,
    'for': TokenType.For,
    'fun': TokenType.Fun,
    'if': TokenType.If,
    'nil': TokenType.Nil,
    'or': TokenType.Or,
    'print': TokenType.Print,
    'return': TokenType.Return,
    'super': TokenType.Super,
    'this': TokenType.This,
    'true': TokenType.True,
    'var': TokenType.Var,
    'while': TokenType.While,
  };

  Scanner({String source}) : _source = source;

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }
    _tokens.add(
        Token(type: TokenType.Eof, lexeme: '', literal: null, line: _line));
    return _tokens;
  }

  void _scanToken() {
    var c = _advance();
    switch (c) {
      // singles
      case '(':
        _addToken_Type(TokenType.LeftParen);
        break;
      case ')':
        _addToken_Type(TokenType.RightParen);
        break;
      case '{':
        _addToken_Type(TokenType.LeftBrace);
        break;
      case '}':
        _addToken_Type(TokenType.RightBrace);
        break;
      case ',':
        _addToken_Type(TokenType.Comma);
        break;
      case '.':
        _addToken_Type(TokenType.Dot);
        break;
      case '-':
        _addToken_Type(TokenType.Minus);
        break;
      case '+':
        _addToken_Type(TokenType.Plus);
        break;
      case ';':
        _addToken_Type(TokenType.Semicolon);
        break;
      case '*':
        _addToken_Type(TokenType.Star);
        break;
      // potentialy double
      case '!':
        _addToken_Type(_match('=') ? TokenType.BangEqual : TokenType.Bang);
        break;
      case '=':
        _addToken_Type(_match('=') ? TokenType.EqualEqual : TokenType.Equal);
        break;
      case '<':
        _addToken_Type(_match('=') ? TokenType.LessEqual : TokenType.Less);
        break;
      case '>':
        _addToken_Type(
            _match('=') ? TokenType.GreaterEqual : TokenType.Greater);
        break;
      // potentialy meaningless
      case '/':
        if (_match('/')) {
          while (_peek() != '\n' && !_isAtEnd()) {
            _advance();
          }
        } else {
          _addToken_Type(TokenType.Slash);
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        break;
      case '\n':
        _line++;
        break;
      // literals
      case '"':
        _string();
        break;
      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          lox.error(_line, 'Unexpected character.');
        }
        break;
    }
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }
    // check for reserved words
    final text = _source.substring(_start, _current);
    var type = _keywords[text];
    type ??= TokenType.Identifier;
    _addToken_Type(type);
  }

  void _number() {
    while (_isDigit(_peek())) {
      _advance();
    }
    // look for fractional part
    if (_peek() == '.' && _isDigit(_peekNext())) {
      // consume "."
      _advance();
      while (_isDigit(_peek())) {
        _advance();
      }
    }
    _addToken_TypeLiteral(
        TokenType.Number, double.parse(_source.substring(_start, _current)));
  }

  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }
    // non-terminated string
    if (_isAtEnd()) {
      lox.error(_line, 'Non-terminated string.');
      return;
    }
    // consume closing "
    _advance();
    // trim ""
    final value = _source.substring(_start + 1, _current - 1);
    _addToken_TypeLiteral(TokenType.String, value);
  }

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (_source[_current] != expected) return false;
    _current++;
    return true;
  }

  String _peek() {
    if (_isAtEnd()) return '\u0000';
    return _source[_current];
  }

  String _peekNext() {
    if (_current + 1 >= _source.length) return '\u0000';
    return _source[_current + 1];
  }

  bool _isAlpha(String c) {
    final char = c.codeUnits.first;
    return ((char >= 'a'.codeUnits.first && char <= 'z'.codeUnits.first) ||
        (char >= 'A'.codeUnits.first && char <= 'Z'.codeUnits.first) ||
        c == '_');
  }

  bool _isAlphaNumeric(String c) {
    return _isAlpha(c) || _isDigit(c);
  }

  bool _isDigit(String c) {
    final char = c.codeUnits.first;
    return char >= '0'.codeUnits.first && char <= '9'.codeUnits.first;
  }

  bool _isAtEnd() {
    return _current >= _source.length;
  }

  String _advance() {
    _current++;
    return _source[_current - 1];
  }

  void _addToken_Type(TokenType type) {
    _addToken_TypeLiteral(type, null);
  }

  void _addToken_TypeLiteral(TokenType type, Object literal) {
    final text = _source.substring(_start, _current);
    _tokens.add(Token(type: type, lexeme: text, literal: literal, line: _line));
  }
}
