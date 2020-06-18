import 'package:dlox/Errors.dart';
import 'package:dlox/Token.dart';

class Environment {
  final Map<String, Object> values = {};
  final Environment enclosing;

  Environment([this.enclosing]);

  void define(String name, Object value) {
    values[name] = value;
  }

  Object operator [](Token name) {
    if (values.containsKey(name.lexeme)) {
      return values[name.lexeme];
    }

    if (enclosing != null) {
      return enclosing[name];
    }

    throw RuntimeException(name, 'Undefined variable ${name.lexeme}.');
  }

  void assign(Token name, Object value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }

    if (enclosing != null) {
      enclosing.assign(name, value);
      return;
    }

    throw RuntimeException(name, 'Undefined variable ${name.lexeme}.');
  }

  Object getAt(int distance, String name) {
    return ancestor(distance).values[name];
  }

  void assignAt(int distance, Token name, Object value) {
    ancestor(distance).values[name.lexeme] = value;
  }

  Environment ancestor(int distance) {
    var environment = this;
    for (var i = 0; i < distance; i++) {
      environment = environment.enclosing;
    }
    return environment;
  }
}
