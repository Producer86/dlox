import 'package:dlox/Errors.dart';
import 'package:dlox/Token.dart';

class Environment {
  final Map<String, Object> _values = {};
  final Environment enclosing;

  Environment([this.enclosing]);

  void define(String name, Object value) {
    _values[name] = value;
  }

  Object operator [](Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    if (enclosing != null) {
      return enclosing[name];
    }

    throw RuntimeException(name, 'Undefined variable ${name.lexeme}.');
  }

  void assign(Token name, Object value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (enclosing != null) {
      enclosing.assign(name, value);
      return;
    }

    throw RuntimeException(name, 'Undefined variable ${name.lexeme}.');
  }
}
