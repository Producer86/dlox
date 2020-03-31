import 'package:dlox/Expr.dart';
// import 'package:dlox/Token.dart';
// import 'package:dlox/TokenType.dart';

class AstPrinter implements ExprVisitor<String> {
  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitBinaryExpr(Binary expr) {
    return _parenthesize(expr.op.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return _parenthesize('group', [expr.expression]);
  }

  @override
  String visitLiteralExpr(Literal expr) {
    if (expr.value == null) return 'nil';
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return _parenthesize(expr.op.lexeme, [expr.right]);
  }

  String _parenthesize(String name, List<Expr> exprs) {
    final builder = StringBuffer();

    builder.write('($name');
    for (var expr in exprs) {
      builder.write(' ');
      builder.write(expr.accept(this));
    }
    builder.write(')');

    return builder.toString();
  }
}

// void main(List<String> args) {
//   final expression = Binary(
//     Unary(
//       Token(type: TokenType.Minus, lexeme: '-', literal: null, line: 1),
//       Literal(123),
//     ),
//     Token(type: TokenType.Star, lexeme: '*', literal: null, line: 1),
//     Grouping(Literal(45.67)),
//   );

//   print(AstPrinter().print(expression));
// }
