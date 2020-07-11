import 'package:dlox/Errors.dart';
import 'package:dlox/LoxClass.dart';
import 'package:dlox/Token.dart';

class LoxInstance {
  final LoxClass _loxClass;
  final Map<String, Object> _fields = {};

  LoxInstance(this._loxClass);

  Object getProp(Token name) {
    if (_fields.containsKey(name.lexeme)) {
      return _fields[name.lexeme];
    }

    final method = _loxClass.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw RuntimeException(name, 'Undefined property "${name.lexeme}".');
  }

  void setProp(Token name, Object value) {
    _fields[name.lexeme] = value;
  }

  @override
  String toString() {
    return '${_loxClass.name} instance';
  }
}
