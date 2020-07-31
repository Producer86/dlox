import 'package:dlox/Token.dart';

abstract class ExprVisitor<R> {
	R visitAssignExpr(AssignExpr expr);
	R visitBinaryExpr(BinaryExpr expr);
	R visitCallExpr(CallExpr expr);
	R visitGetExpr(GetExpr expr);
	R visitGroupingExpr(GroupingExpr expr);
	R visitLiteralExpr(LiteralExpr expr);
	R visitLogicalExpr(LogicalExpr expr);
	R visitSetExpr(SetExpr expr);
	R visitSuperExpr(SuperExpr expr);
	R visitThisExpr(ThisExpr expr);
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

class CallExpr implements Expr {
	CallExpr(this.callee, this.paren, this.arguments);

	final Expr callee;
	final Token paren;
	final List<Expr> arguments;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitCallExpr(this);
	}
}

class GetExpr implements Expr {
	GetExpr(this.object, this.name);

	final Expr object;
	final Token name;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitGetExpr(this);
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

class LogicalExpr implements Expr {
	LogicalExpr(this.left, this.op, this.right);

	final Expr left;
	final Token op;
	final Expr right;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitLogicalExpr(this);
	}
}

class SetExpr implements Expr {
	SetExpr(this.object, this.name, this.value);

	final Expr object;
	final Token name;
	final Expr value;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitSetExpr(this);
	}
}

class SuperExpr implements Expr {
	SuperExpr(this.keyword, this.method);

	final Token keyword;
	final Token method;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitSuperExpr(this);
	}
}

class ThisExpr implements Expr {
	ThisExpr(this.keyword);

	final Token keyword;

@override
	R accept<R>(ExprVisitor<R> visitor) {
		return visitor.visitThisExpr(this);
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

