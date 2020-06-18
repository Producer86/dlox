import 'package:dlox/Expr.dart';
import 'package:dlox/Token.dart';

abstract class StmtVisitor<R> {
  R visitBlockStmt(BlockStmt stmt);
  R visitExpressionStmt(ExpressionStmt stmt);
  R visitFunctionStmt(FunctionStmt stmt);
  R visitIfStmt(IfStmt stmt);
  R visitWhileStmt(WhileStmt stmt);
  R visitPrintStmt(PrintStmt stmt);
  R visitReturnStmt(ReturnStmt stmt);
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

class FunctionStmt implements Stmt {
  FunctionStmt(this.name, this.params, this.body);

  final Token name;
  final List<Token> params;
  final List<Stmt> body;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitFunctionStmt(this);
  }
}

class IfStmt implements Stmt {
  IfStmt(this.condition, this.thenBranch, this.elseBranch);

  final Expr condition;
  final Stmt thenBranch;
  final Stmt elseBranch;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitIfStmt(this);
  }
}

class WhileStmt implements Stmt {
  WhileStmt(this.condition, this.body);

  final Expr condition;
  final Stmt body;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitWhileStmt(this);
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

class ReturnStmt implements Stmt {
  ReturnStmt(this.keyword, this.value);

  final Token keyword;
  final Expr value;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitReturnStmt(this);
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
