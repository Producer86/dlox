import 'package:dlox/Token.dart';

abstract class ExprVisitor<R> {
  R visitBinaryExpr(Binary expr);
  R visitGroupingExpr(Grouping expr);
  R visitLiteralExpr(Literal expr);
  R visitUnaryExpr(Unary expr);
}

abstract class Expr {
  R accept<R>(ExprVisitor<R> visitor);
}

class Binary implements Expr {
  Binary(this.left, this.op, this.right);

  final Expr left;
  final Token op;
  final Expr right;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}

class Grouping implements Expr {
  Grouping(this.expression);

  final Expr expression;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}

class Literal implements Expr {
  Literal(this.value);

  final Object value;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}

class Unary implements Expr {
  Unary(this.op, this.right);

  final Token op;
  final Expr right;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}
