import 'dart:collection';

import 'package:dlox/Expr.dart';
import 'package:dlox/Interpreter.dart';
import 'package:dlox/Stmt.dart';
import 'package:dlox/Token.dart';
import 'package:dlox/Lox.dart' as lox;

enum _FunctionType {
  None,
  Function,
}

class Resolver implements ExprVisitor<void>, StmtVisitor<void> {
  final Interpreter _interpreter;
  final _scopes = ListQueue<Map<String, bool>>();
  _FunctionType _currentFunction = _FunctionType.None;

  Resolver(this._interpreter);

  @override
  void visitBlockStmt(BlockStmt stmt) {
    _beginScope();
    resolve(stmt.statements);
    _endScope();
  }

  @override
  void visitFunctionStmt(FunctionStmt stmt) {
    _declare(stmt.name);
    _define(stmt.name);
    _resolveFunction(stmt, _FunctionType.Function);
  }

  @override
  void visitVarStmt(VarStmt stmt) {
    _declare(stmt.name);
    if (stmt.initializer != null) {
      _resolveExpr(stmt.initializer);
    }
    _define(stmt.name);
  }

  @override
  void visitAssignExpr(AssignExpr expr) {
    _resolveExpr(expr.value);
    _resolveLocal(expr, expr.name);
  }

  @override
  void visitVariableExpr(VariableExpr expr) {
    if (_scopes.isNotEmpty && _scopes.last[expr.name.lexeme] == false) {
      lox.error_token(
          expr.name, 'Cannot read local variable in its own initializer.');
    }
    _resolveLocal(expr, expr.name);
  }

  @override
  void visitExpressionStmt(ExpressionStmt stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  void visitIfStmt(IfStmt stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.thenBranch);
    if (stmt.elseBranch != null) _resolveStmt(stmt.elseBranch);
  }

  @override
  void visitPrintStmt(PrintStmt stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  void visitReturnStmt(ReturnStmt stmt) {
    if (_currentFunction == _FunctionType.None) {
      lox.error_token(stmt.keyword, 'Cannot return from top-level code.');
    }
    if (stmt.value != null) _resolveExpr(stmt.value);
  }

  @override
  void visitBinaryExpr(BinaryExpr expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  void visitCallExpr(CallExpr expr) {
    _resolveExpr(expr.callee);
    for (var argument in expr.arguments) {
      _resolveExpr(argument);
    }
  }

  void _resolveFunction(FunctionStmt stmt, _FunctionType type) {
    final enclosingFunction = _currentFunction;
    _currentFunction = type;

    _beginScope();
    for (var param in stmt.params) {
      _declare(param);
      _define(param);
    }
    resolve(stmt.body);
    _endScope();

    _currentFunction = enclosingFunction;
  }

  @override
  void visitWhileStmt(WhileStmt stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.body);
  }

  @override
  void visitGroupingExpr(GroupingExpr expr) {
    _resolveExpr(expr.expression);
  }

  @override
  void visitLiteralExpr(LiteralExpr expr) {}

  @override
  void visitLogicalExpr(LogicalExpr expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  void visitUnaryExpr(UnaryExpr expr) {
    _resolveExpr(expr.right);
  }

  void resolve(List<Stmt> statements) {
    for (var statement in statements) {
      _resolveStmt(statement);
    }
  }

  void _resolveStmt(Stmt stmt) {
    stmt.accept(this);
  }

  void _resolveExpr(Expr expr) {
    expr.accept(this);
  }

  void _resolveLocal(Expr expr, Token name) {
    for (var i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes.elementAt(i).containsKey(name.lexeme)) {
        _interpreter.resolve(expr, _scopes.length - 1 - i);
        return;
      }
    }
  }

  void _beginScope() {
    _scopes.addLast(<String, bool>{});
  }

  void _endScope() {
    _scopes.removeLast();
  }

  void _declare(Token name) {
    if (_scopes.isEmpty) return;

    final scope = _scopes.last;
    if (scope.containsKey(name.lexeme)) {
      lox.error_token(name,
          'Variable with name ${name.lexeme} already declared in this scope.');
    }
    scope[name.lexeme] = false;
  }

  void _define(Token name) {
    if (_scopes.isEmpty) return;
    _scopes.last[name.lexeme] = true;
  }
}