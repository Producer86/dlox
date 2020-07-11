import 'package:dlox/Environment.dart';
import 'package:dlox/Interpreter.dart';
import 'package:dlox/LoxCallable.dart';
import 'package:dlox/LoxInstance.dart';
import 'package:dlox/Return.dart';
import 'package:dlox/Stmt.dart';

class LoxFunction implements LoxCallable {
  final bool _isInitializer;
  final FunctionStmt declaration;
  final Environment closure;

  LoxFunction(this.declaration, this.closure, {bool isInitializer = false})
      : _isInitializer = isInitializer;

  LoxFunction bind(LoxInstance instance) {
    final environment = Environment(closure);
    environment.define('this', instance);
    return LoxFunction(declaration, environment, isInitializer: _isInitializer);
  }

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
      if (_isInitializer) return closure.getAt(0, 'this');
      return returnValue.value;
    }

    if (_isInitializer) return closure.getAt(0, 'this');
    return null;
  }

  @override
  String toString() {
    return '<fn ${declaration.name.lexeme}>';
  }
}
