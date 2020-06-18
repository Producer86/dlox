import 'package:dlox/Interpreter.dart';

abstract class LoxCallable {
  int get arity;
  Object call(Interpreter interpreter, List<Object> arguments);
}
