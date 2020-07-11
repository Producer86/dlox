import 'dart:collection';

import 'package:dlox/Environment.dart';
import 'package:dlox/Errors.dart';
import 'package:dlox/Expr.dart';
import 'package:dlox/LoxCallable.dart';
import 'package:dlox/LoxClass.dart';
import 'package:dlox/LoxFunction.dart';
import 'package:dlox/LoxInstance.dart';
import 'package:dlox/Return.dart';
import 'package:dlox/Stmt.dart';
import 'package:dlox/Token.dart';
import 'package:dlox/TokenType.dart';
import 'package:dlox/Lox.dart' as lox;

class Interpreter implements ExprVisitor<Object>, StmtVisitor<void> {
  final Environment globals = Environment();
  final HashMap _locals = HashMap<Expr, int>();
  Environment _environment;

  Interpreter() {
    _environment = globals;

    globals.define('clock', ClockFn());
  }

  void interpret(List<Stmt> statements) {
    try {
      for (var statement in statements) {
        _execute(statement);
      }
    } on RuntimeException catch (e) {
      lox.runtimeException(e);
    }
  }

  @override
  void visitExpressionStmt(ExpressionStmt stmt) {
    _evaluate(stmt.expression);
  }

  @override
  void visitFunctionStmt(FunctionStmt stmt) {
    final function = LoxFunction(stmt, _environment);
    _environment.define(stmt.name.lexeme, function);
  }

  @override
  void visitPrintStmt(PrintStmt stmt) {
    final value = _evaluate(stmt.expression);
    print(_stringify(value));
  }

  @override
  void visitReturnStmt(ReturnStmt stmt) {
    Object value;
    if (stmt.value != null) value = _evaluate(stmt.value);
    throw Return(value);
  }

  @override
  void visitVarStmt(VarStmt stmt) {
    Object value;
    if (stmt.initializer != null) {
      value = _evaluate(stmt.initializer);
    }

    _environment.define(stmt.name.lexeme, value);
  }

  @override
  void visitIfStmt(IfStmt stmt) {
    if (_isTruthy(_evaluate(stmt.condition))) {
      _execute(stmt.thenBranch);
    } else if (stmt.elseBranch != null) {
      _execute(stmt.thenBranch);
    }
  }

  @override
  void visitWhileStmt(WhileStmt stmt) {
    while (_isTruthy(_evaluate(stmt.condition))) {
      _execute(stmt.body);
    }
  }

  @override
  void visitBlockStmt(BlockStmt stmt) {
    executeBlock(stmt.statements, Environment(_environment));
  }

  @override
  void visitClassStmt(ClassStmt stmt) {
    _environment.define(stmt.name.lexeme, null);
// why?
    final methods = <String, LoxFunction>{};
    for (var method in stmt.methods) {
      final function = LoxFunction(method, _environment,
          isInitializer: method.name.lexeme == 'init');
      methods[method.name.lexeme] = function;
    }

    final loxClass = LoxClass(stmt.name.lexeme, methods);
    _environment.assign(stmt.name, loxClass);
  }

  @override
  Object visitLiteralExpr(LiteralExpr expr) {
    return expr.value;
  }

  @override
  Object visitLogicalExpr(LogicalExpr expr) {
    final left = _evaluate(expr.left);

    if (expr.op.type == TokenType.Or) {
      if (_isTruthy(left)) return left;
    } else if (!_isTruthy(left)) return left;

    return _evaluate(expr.right);
  }

  @override
  Object visitSetExpr(SetExpr expr) {
    final object = _evaluate(expr.object);

    if (!(object is LoxInstance)) {
      throw RuntimeException(expr.name, 'Only instances have fields');
    }

    final value = _evaluate(expr.value);
    (object as LoxInstance).setProp(expr.name, value);

    return value;
  }

  @override
  Object visitThisExpr(ThisExpr expr) {
    return _lookUpVariable(expr.keyword, expr);
  }

  @override
  Object visitVariableExpr(VariableExpr expr) {
    return _lookUpVariable(expr.name, expr);
  }

  @override
  Object visitGroupingExpr(GroupingExpr expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object visitUnaryExpr(UnaryExpr expr) {
    final right = _evaluate(expr.right);

    switch (expr.op.type) {
      case TokenType.Minus:
        _checkNumberOperand(expr.op, right);
        return -(right as double);
      case TokenType.Bang:
        return !_isTruthy(right);
      default:
        break;
    }

    return null;
  }

  @override
  Object visitAssignExpr(AssignExpr expr) {
    final value = _evaluate(expr.value);

    final distance = _locals[expr];
    if (distance != null) {
      _environment.assignAt(distance, expr.name, value);
    } else {
      globals.assign(expr.name, value);
    }

    return value;
  }

  @override
  Object visitBinaryExpr(BinaryExpr expr) {
    final left = _evaluate(expr.left);
    final right = _evaluate(expr.right);

    switch (expr.op.type) {
      case TokenType.Greater:
        _checkNumberOperands(expr.op, left, right);
        return (left as double) > (right as double);
      case TokenType.GreaterEqual:
        _checkNumberOperands(expr.op, left, right);
        return (left as double) >= (right as double);
      case TokenType.Less:
        _checkNumberOperands(expr.op, left, right);
        return (left as double) < (right as double);
      case TokenType.LessEqual:
        _checkNumberOperands(expr.op, left, right);
        return (left as double) <= (right as double);
      case TokenType.BangEqual:
        return !_isEqual(left, right);
      case TokenType.EqualEqual:
        return _isEqual(left, right);
      case TokenType.Minus:
        _checkNumberOperands(expr.op, left, right);
        return (left as double) - (right as double);
      case TokenType.Plus:
        if (left is double && right is double) {
          return left + right;
        }
        if (left is String && right is String) {
          return left + right;
        }
        throw RuntimeException(
            expr.op, 'Operands must be two numbers or two strings');
        break;
      case TokenType.Slash:
        _checkNumberOperands(expr.op, left, right);
        return (left as double) / (right as double);
      case TokenType.Star:
        _checkNumberOperands(expr.op, left, right);
        return (left as double) * (right as double);
      default:
        break;
    }

    return null;
  }

  @override
  Object visitCallExpr(CallExpr expr) {
    var callee = _evaluate(expr.callee);

    final arguments = <Object>[];
    for (var argument in expr.arguments) {
      arguments.add(_evaluate(argument));
    }

    if (!(callee is LoxCallable)) {
      throw RuntimeException(
          expr.paren, 'Can only call functions and classes.');
    }

    final function = callee as LoxCallable;

    if (arguments.length != function.arity) {
      throw RuntimeException(expr.paren,
          'Expected ${function.arity} arguments but got ${arguments.length}.');
    }

    return function.call(this, arguments);
  }

  @override
  Object visitGetExpr(GetExpr expr) {
    final object = _evaluate(expr.object);

    if (object is LoxInstance) {
      return object.getProp(expr.name);
    }

    throw RuntimeException(expr.name, 'Only instances have properties.');
  }

  void executeBlock(List<Stmt> statements, Environment environment) {
    final previous = _environment;
    try {
      _environment = environment;
      for (var statement in statements) {
        _execute(statement);
      }
    } finally {
      _environment = previous;
    }
  }

  Object _evaluate(Expr expr) {
    return expr.accept(this);
  }

  void _execute(Stmt stmt) {
    stmt.accept(this);
  }

  bool _isTruthy(Object object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  bool _isEqual(Object a, Object b) {
    return a == b;
  }

  String _stringify(Object object) {
    if (object == null) return 'nil';

    if (object is double) {
      var text = object.toString();
      if (text.endsWith('.0')) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }

    return object.toString();
  }

  void _checkNumberOperand(Token op, Object operand) {
    if (operand is! double) {
      throw RuntimeException(op, 'Operand must be a number.');
    }
  }

  void _checkNumberOperands(Token op, Object a, Object b) {
    if (a is! double || b is! double) {
      throw RuntimeException(op, 'Operands must be numbers.');
    }
  }

  void resolve(Expr expr, int depth) {
    _locals[expr] = depth;
  }

  Object _lookUpVariable(Token name, Expr expr) {
    final distance = _locals[expr];
    if (distance != null) {
      return _environment.getAt(distance, name.lexeme);
    } else {
      return globals[name];
    }
  }
}

class ClockFn implements LoxCallable {
  @override
  int get arity => 0;

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    return DateTime.now().millisecondsSinceEpoch / 1000;
  }

  @override
  String toString() {
    return '<native fn>';
  }
}
