import 'package:dlox/Environment.dart';
import 'package:dlox/Interpreter.dart';
import 'package:dlox/LoxCallable.dart';
import 'package:dlox/Return.dart';
import 'package:dlox/Stmt.dart';

class LoxFunction implements LoxCallable {
  final FunctionStmt declaration;
  final Environment closure;

  LoxFunction({this.declaration, this.closure});

  @override
  int get arity => declaration.params.length;

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    final environment = Environment(closure);
    for (var i = 0; i < declaration.params.length; i++) {
      environment.define(declaration.params[i].lexeme, arguments[i]);
    }

    try {
      interpreter.executeBlock(declaration.body, environment);
    } on Return catch (returnValue) {
      return returnValue.value;
    }
    return null;
  }

  @override
  String toString() {
    return '<fn ${declaration.name.lexeme}>';
  }
}
