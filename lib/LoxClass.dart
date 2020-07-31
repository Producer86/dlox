import 'package:dlox/Interpreter.dart';
import 'package:dlox/LoxCallable.dart';
import 'package:dlox/LoxFunction.dart';
import 'package:dlox/LoxInstance.dart';

class LoxClass implements LoxCallable {
  final Map<String, LoxFunction> _methods;
  final String name;
  final LoxClass superclass;

  LoxClass(this.name, this.superclass, this._methods);

  LoxFunction findMethod(String name) {
    if (_methods.containsKey(name)) {
      return _methods[name];
    }
    if (superclass != null) {
      return superclass.findMethod(name);
    }
    return null;
  }

  @override
  String toString() {
    return name;
  }

  @override
  int get arity {
    final initializer = findMethod('init');
    if (initializer == null) {
      return 0;
    }
    return initializer.arity;
  }

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    final instance = LoxInstance(this);
    final initializer = findMethod('init');
    if (initializer != null) {
      initializer.bind(instance).call(interpreter, arguments);
    }
    return instance;
  }
}
