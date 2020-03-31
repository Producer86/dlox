import 'package:dlox/Expr.dart';
import 'package:dlox/Stmt.dart';
import 'package:dlox/Token.dart';
import 'package:dlox/TokenType.dart';
import 'package:dlox/Lox.dart' as lox;

class Interpreter implements ExprVisitor<Object>, StmtVisitor<void> {
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
  void visitExpressionStmt(Expression stmt) {
    _evaluate(stmt.expression);
  }

  @override
  void visitPrintStmt(Print stmt) {
    final value = _evaluate(stmt.expression);
    print(_stringify(value));
  }

  @override
  Object visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object visitGroupingExpr(Grouping expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object visitUnaryExpr(Unary expr) {
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
  Object visitBinaryExpr(Binary expr) {
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
    // we aint no java here
    // if (a == null && b == null) return true;
    // if (a == null) return false;
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
}

class RuntimeException implements Exception {
  final Token token;
  final String message;

  const RuntimeException(this.token, this.message);
}
