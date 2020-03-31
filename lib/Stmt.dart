import 'package:dlox/Expr.dart';
import 'package:dlox/Token.dart';

abstract class StmtVisitor<R> {
  R visitExpressionStmt(Expression stmt);
  R visitPrintStmt(Print stmt);
}

abstract class Stmt {
  R accept<R>(StmtVisitor<R> visitor);
}

class Expression implements Stmt {
  Expression(this.expression);

  final Expr expression;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}

class Print implements Stmt {
  Print(this.expression);

  final Expr expression;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitPrintStmt(this);
  }
}
