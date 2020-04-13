import 'package:dlox/Errors.dart';
import 'package:dlox/Expr.dart';
import 'package:dlox/Lox.dart' as lox;
import 'package:dlox/Stmt.dart';
import 'package:dlox/Token.dart';
import 'package:dlox/TokenType.dart';

/*
program -> declaration* EOF ;

declaration -> varDecl | statement ;

varDecl -> "var" IDENTIFIER ( "=" expression )? ";" ;

statement -> exprStmt | forStmt | ifStmt | printStmt | whileStmt | block ;
forStmt -> "for" "(" ( varDecl | exprStmt | ";" ) expression? ";" expression? ")" statement ;
ifStmt -> "if" "(" expression ")" statement ( "else" statement )? ;
whileStmt -> "while" "(" expression ")" statement ;
printStmt -> "print" expression ";" ;
block -> "{" declaration* "}" ;
exprStmt -> expression ";" ;

expression -> assignment ;
assignment -> IDENTIFIER "=" assignment | logic_or ;
logic_or -> logic_and ( "or" logic_and )* ;
logic_and -> equality ( "and" equality )* ;
equality -> comparison ( ( "!=" | "==" ) comparison )* ;
comparison -> addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
addition -> multiplication ( ( "+" | "-" )  multiplication )* ;
multiplication -> unary ( ( "*" | "/" ) unary )* ;
unary -> ( "!" | "-" ) unary | primary ;
primary -> NUMBER | STRING | "false" | "true" | "nil" | "(" expression ")" | IDENTIFIER ;
*/

class Parser {
  Parser(this._tokens);

  final List<Token> _tokens;
  int _current = 0;

  List<Stmt> parse() {
    final statements = <Stmt>[];
    while (!_isAtEnd()) {
      statements.add(_declaration());
    }
    return statements;
  }

  Stmt _declaration() {
    try {
      if (_match([TokenType.Var])) {
        return _varDeclaration();
      }
      return _statement();
    } catch (e) {
      _synchronize();
      return null;
    }
  }

  Stmt _varDeclaration() {
    final name = _consume(TokenType.Identifier, 'Expected variable name.');

    Expr initializer;
    if (_match([TokenType.Equal])) {
      initializer = _expression();
    }

    _consume(TokenType.Semicolon, 'Expected ";" after variable declaration.');
    return VarStmt(name, initializer);
  }

  Stmt _statement() {
    if (_match([TokenType.For])) return _forStatement();
    if (_match([TokenType.If])) return _ifStatement();
    if (_match([TokenType.Print])) return _printStatement();
    if (_match([TokenType.While])) return _whileStatement();
    if (_match([TokenType.LeftBrace])) return BlockStmt(_block());
    return _expressionStatement();
  }

  Stmt _forStatement() {
    _consume(TokenType.LeftParen, 'Expected "(" after "for".');

    Stmt initializer;
    if (_match([TokenType.Semicolon])) {
    } else if (_match([TokenType.Var])) {
      initializer = _varDeclaration();
    } else {
      initializer = _expressionStatement();
    }

    Expr condition;
    if (!_check(TokenType.Semicolon)) {
      condition = _expression();
    }
    _consume(TokenType.Semicolon, 'Expected ";" after loop condition.');

    Expr increment;
    if (!_check(TokenType.RightParen)) {
      increment = _expression();
    }

    _consume(TokenType.RightParen, 'Expected ")" after for clauses.');
    var body = _statement();

    if (increment != null) {
      body = BlockStmt([body, ExpressionStmt(increment)]);
    }

    condition ??= LiteralExpr(true);

    body = WhileStmt(condition, body);

    if (initializer != null) {
      body = BlockStmt([initializer, body]);
    }

    return body;
  }

  Stmt _ifStatement() {
    _consume(TokenType.LeftParen, 'Expected "(" after "if".');
    final condition = _expression();
    _consume(TokenType.RightParen, 'Expected ")" after if condition.');

    final thenBranch = _statement();
    Stmt elseBrnach;
    if (_match([TokenType.Else])) {
      elseBrnach = _statement();
    }

    return IfStmt(condition, thenBranch, elseBrnach);
  }

  Stmt _printStatement() {
    final value = _expression();
    _consume(TokenType.Semicolon, 'Expected ";" after value.');
    return PrintStmt(value);
  }

  Stmt _whileStatement() {
    _consume(TokenType.LeftParen, 'Expected "(" after "while".');
    final condition = _expression();
    _consume(TokenType.RightParen, 'Expected ")" after condition.');
    final body = _statement();
    return WhileStmt(condition, body);
  }

  List<Stmt> _block() {
    final statements = <Stmt>[];

    while (!_check(TokenType.RightBrace) && !_isAtEnd()) {
      statements.add(_declaration());
    }

    _consume(TokenType.RightBrace, 'Expected "}" after block.');
    return statements;
  }

  Stmt _expressionStatement() {
    final expr = _expression();
    _consume(TokenType.Semicolon, 'Expected ";" after value.');
    return ExpressionStmt(expr);
  }

  Expr _expression() {
    return _assignment();
  }

  Expr _assignment() {
    var expr = _or();

    if (_match([TokenType.Equal])) {
      final equals = _previous();
      final value = _assignment();

      if (expr is VariableExpr) {
        final name = expr.name;
        return AssignExpr(name, value);
      }

      _error(equals, 'Invalid assignment target.');
    }
    return expr;
  }

  Expr _or() {
    var expr = _and();

    while (_match([TokenType.Or])) {
      final op = _previous();
      final right = _and();
      expr = LogicalExpr(expr, op, right);
    }

    return expr;
  }

  Expr _and() {
    var expr = _equality();

    while (_match([TokenType.And])) {
      final op = _previous();
      final right = _equality();
      expr = LogicalExpr(expr, op, right);
    }

    return expr;
  }

  Expr _equality() {
    var expr = _comparison();

    while (_match([
      TokenType.BangEqual,
      TokenType.EqualEqual,
    ])) {
      final op = _previous();
      final right = _comparison();
      expr = BinaryExpr(expr, op, right);
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
      expr = BinaryExpr(expr, op, right);
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
      expr = BinaryExpr(expr, op, right);
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
      expr = BinaryExpr(expr, op, right);
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
      return UnaryExpr(op, right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.False])) {
      return LiteralExpr(false);
    }
    if (_match([TokenType.True])) {
      return LiteralExpr(true);
    }
    if (_match([TokenType.Nil])) {
      return LiteralExpr(null);
    }
    if (_match([TokenType.Number, TokenType.String])) {
      return LiteralExpr(_previous().literal);
    }

    if (_match([TokenType.Identifier])) {
      return VariableExpr(_previous());
    }

    if (_match([TokenType.LeftParen])) {
      final expr = _expression();
      _consume(TokenType.RightParen, 'Expected ")" after expression.');
      return GroupingExpr(expr);
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
