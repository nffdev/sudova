import 'dart:math';
import 'difficulty.dart';

enum Operation { add, subtract, multiply, divide }

class MentalCalcProblem {
  final int a;
  final int b;
  final Operation operation;
  final int answer;

  MentalCalcProblem({
    required this.a,
    required this.b,
    required this.operation,
    required this.answer,
  });

  String get operationSymbol => switch (operation) {
        Operation.add => '+',
        Operation.subtract => '-',
        Operation.multiply => '\u00d7',
        Operation.divide => '\u00f7',
      };

  String get display => '$a $operationSymbol $b';

  factory MentalCalcProblem.generate(Difficulty difficulty) {
    final rng = Random();

    return switch (difficulty) {
      Difficulty.easy => _generateEasy(rng),
      Difficulty.medium => _generateMedium(rng),
      Difficulty.hard => _generateHard(rng),
      Difficulty.expert => _generateExpert(rng),
    };
  }

  static MentalCalcProblem _generateEasy(Random rng) {
    final op =
        rng.nextBool() ? Operation.add : Operation.subtract;
    final a = rng.nextInt(20) + 1;
    final b = rng.nextInt(20) + 1;
    if (op == Operation.add) {
      return MentalCalcProblem(a: a, b: b, operation: op, answer: a + b);
    }
    final big = max(a, b);
    final small = min(a, b);
    return MentalCalcProblem(
        a: big, b: small, operation: op, answer: big - small);
  }

  static MentalCalcProblem _generateMedium(Random rng) {
    final ops = [Operation.add, Operation.subtract, Operation.multiply];
    final op = ops[rng.nextInt(ops.length)];
    if (op == Operation.multiply) {
      final a = rng.nextInt(12) + 2;
      final b = rng.nextInt(12) + 2;
      return MentalCalcProblem(a: a, b: b, operation: op, answer: a * b);
    }
    final a = rng.nextInt(50) + 10;
    final b = rng.nextInt(50) + 10;
    if (op == Operation.add) {
      return MentalCalcProblem(a: a, b: b, operation: op, answer: a + b);
    }
    final big = max(a, b);
    final small = min(a, b);
    return MentalCalcProblem(
        a: big, b: small, operation: op, answer: big - small);
  }

  static MentalCalcProblem _generateHard(Random rng) {
    final ops = Operation.values;
    final op = ops[rng.nextInt(ops.length)];
    if (op == Operation.divide) {
      final b = rng.nextInt(11) + 2;
      final answer = rng.nextInt(15) + 2;
      return MentalCalcProblem(
          a: b * answer, b: b, operation: op, answer: answer);
    }
    if (op == Operation.multiply) {
      final a = rng.nextInt(20) + 5;
      final b = rng.nextInt(15) + 3;
      return MentalCalcProblem(a: a, b: b, operation: op, answer: a * b);
    }
    final a = rng.nextInt(200) + 50;
    final b = rng.nextInt(200) + 50;
    if (op == Operation.add) {
      return MentalCalcProblem(a: a, b: b, operation: op, answer: a + b);
    }
    final big = max(a, b);
    final small = min(a, b);
    return MentalCalcProblem(
        a: big, b: small, operation: op, answer: big - small);
  }

  static MentalCalcProblem _generateExpert(Random rng) {
    final ops = Operation.values;
    final op = ops[rng.nextInt(ops.length)];
    if (op == Operation.divide) {
      final b = rng.nextInt(20) + 3;
      final answer = rng.nextInt(30) + 5;
      return MentalCalcProblem(
          a: b * answer, b: b, operation: op, answer: answer);
    }
    if (op == Operation.multiply) {
      final a = rng.nextInt(50) + 10;
      final b = rng.nextInt(30) + 5;
      return MentalCalcProblem(a: a, b: b, operation: op, answer: a * b);
    }
    final a = rng.nextInt(500) + 100;
    final b = rng.nextInt(500) + 100;
    if (op == Operation.add) {
      return MentalCalcProblem(a: a, b: b, operation: op, answer: a + b);
    }
    final big = max(a, b);
    final small = min(a, b);
    return MentalCalcProblem(
        a: big, b: small, operation: op, answer: big - small);
  }
}
