import 'package:dlox/Token.dart';

abstract class ExprVisitor<R> {
	R visitAssignExpr(AssignExpr expr);
	R visitBinaryExpr(BinaryExpr expr);
	R visitGroupingExpr(GroupingExpr expr);
	R visitLiteralExpr(LiteralExpr expr);
	R visitUnaryExpr(UnaryExpr expr);
	R visitVariableExpr(VariableExpr expr);
}

abstract class Expr {
	R accept<R>(ExprVisitor<R> visitor);
}

class AssignExpr implements Expr {
	AssignExpr(this.name, this.value);

	final Token name;
	final Expr value;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitAssignExpr(this);
	}
}

class BinaryExpr implements Expr {
	BinaryExpr(this.left, this.op, this.right);

	final Expr left;
	final Token op;
	final Expr right;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitBinaryExpr(this);
	}
}

class GroupingExpr implements Expr {
	GroupingExpr(this.expression);

	final Expr expression;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitGroupingExpr(this);
	}
}

class LiteralExpr implements Expr {
	LiteralExpr(this.value);

	final Object value;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitLiteralExpr(this);
	}
}

class UnaryExpr implements Expr {
	UnaryExpr(this.op, this.right);

	final Token op;
	final Expr right;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitUnaryExpr(this);
	}
}

class VariableExpr implements Expr {
	VariableExpr(this.name);

	final Token name;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitVariableExpr(this);
	}
}

