import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    print('Usage: generate_ast <output directory>');
    exit(1);
  }
  var outputDir = arguments.first;

  defineAst(outputDir, 'Expr', [
    'Assign   : Token name, Expr value',
    'Binary   : Expr left, Token op, Expr right',
    'Grouping : Expr expression',
    'Literal  : Object value',
    'Logical  : Expr left, Token op, Expr right',
    'Unary    : Token op, Expr right',
    'Variable : Token name',
  ]);

  defineAst(outputDir, 'Stmt', [
    'Block      : List<Stmt> statements',
    'Expression : Expr expression',
    'If         : Expr condition, Stmt thenBranch, Stmt elseBranch',
    'While      : Expr condition, Stmt body',
    'Print      : Expr expression',
    'Var        : Token name, Expr initializer',
  ]);
}

void defineAst(String outputDir, String baseName, List<String> types) {
  final path = '$outputDir/$baseName.dart';
  final file = File(path);
  final sink = file.openWrite();
  sink.writeln("import 'package:dlox/Token.dart';");
  defineVisitor(sink, baseName, types);
  sink.writeln('abstract class $baseName {');
  sink.writeln('\tR accept<R>(${baseName}Visitor<R> visitor);');
  sink.writeln('}');
  sink.writeln();
  for (var type in types) {
    final className = type.split(':')[0].trim();
    final fields = type.split(':')[1].trim();
    defineType(sink, baseName, className, fields);
  }
  sink.close();
}

void defineType(
    IOSink sink, String baseName, String className, String fieldList) {
  sink.writeln('class $className$baseName implements $baseName {');
  // constructor
  final paramList = <String>[];
  final fields = fieldList.split(', ');
  for (var field in fields) {
    paramList.add('this.' + field.split(' ')[1]);
  }
  sink.writeln('\t$className$baseName(${paramList.join(', ')});');
  // fields
  sink.writeln();
  for (var field in fields) {
    sink.writeln('\tfinal $field;');
  }
  // Visitor pattern
  sink.writeln();
  sink.writeln('@override');
  sink.writeln('\tR accept<R>(${baseName}Visitor<R> visitor) {');
  sink.writeln('\t\treturn visitor.visit$className$baseName(this);');
  sink.writeln('\t}');
  sink.writeln('}');
  sink.writeln();
}

void defineVisitor(IOSink sink, String baseName, List<String> types) {
  sink.writeln();
  sink.writeln('abstract class ${baseName}Visitor<R> {');
  for (var type in types) {
    final typeName = type.split(':')[0].trim();
    sink.writeln(
        '\tR visit$typeName$baseName($typeName$baseName ${baseName.toLowerCase()});');
  }
  sink.writeln('}');
  sink.writeln();
}
