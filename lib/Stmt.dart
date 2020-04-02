import 'package:dlox/Expr.dart';
import 'package:dlox/Token.dart';

abstract class StmtVisitor<R> {
  R visitBlockStmt(BlockStmt stmt);
  R visitExpressionStmt(ExpressionStmt stmt);
  R visitPrintStmt(PrintStmt stmt);
  R visitVarStmt(VarStmt stmt);
}

abstract class Stmt {
  R accept<R>(StmtVisitor<R> visitor);
}

class BlockStmt implements Stmt {
  BlockStmt(this.statements);

  final List<Stmt> statements;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitBlockStmt(this);
  }
}

class ExpressionStmt implements Stmt {
  ExpressionStmt(this.expression);

  final Expr expression;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}

class PrintStmt implements Stmt {
  PrintStmt(this.expression);

  final Expr expression;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitPrintStmt(this);
  }
}

class VarStmt implements Stmt {
  VarStmt(this.name, this.initializer);

  final Token name;
  final Expr initializer;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitVarStmt(this);
  }
}
