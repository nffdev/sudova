import 'dart:math';
import 'difficulty.dart';

enum CellType { number, operatorCell, equals, empty, result }

class CrossMathCell {
  final CellType type;
  final int? value;
  final String? operator;
  final bool isHidden;
  int? userValue;

  CrossMathCell({
    required this.type,
    this.value,
    this.operator,
    this.isHidden = false,
    this.userValue,
  });

  bool get isFilled => type == CellType.number && (!isHidden || userValue != null);
  bool get isCorrect => !isHidden || userValue == value;

  String get display {
    if (type == CellType.operatorCell) return operator ?? '';
    if (type == CellType.equals) return '=';
    if (type == CellType.empty) return '';
    if (type == CellType.result) return '${value ?? ''}';
    if (isHidden) return userValue != null ? '$userValue' : '';
    return '${value ?? ''}';
  }
}

class CrossMathModel {
  final List<List<CrossMathCell>> grid;
  final int rows;
  final int cols;

  CrossMathModel({required this.grid, required this.rows, required this.cols});

  bool get isComplete {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.type == CellType.number && cell.isHidden && !cell.isCorrect) {
          return false;
        }
      }
    }
    return true;
  }

  int get hiddenCount {
    var count = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell.type == CellType.number && cell.isHidden && cell.userValue == null) {
          count++;
        }
      }
    }
    return count;
  }

  /// Grid layout (7 cols x 7 rows):
  ///   a  op  b  =  r
  ///  op     op     op
  ///   c  op  d  =  r
  ///   =      =      =
  ///   r  op  r  =  r
  factory CrossMathModel.generate(Difficulty difficulty) {
    final rng = Random();
    final maxVal = switch (difficulty) {
      Difficulty.easy => 10,
      Difficulty.medium => 15,
      Difficulty.hard => 20,
      Difficulty.expert => 30,
    };
    final hiddenRatio = switch (difficulty) {
      Difficulty.easy => 0.3,
      Difficulty.medium => 0.5,
      Difficulty.hard => 0.65,
      Difficulty.expert => 0.8,
    };

    // 4 core numbers
    int a, b, c, d;
    String hOp1, hOp2, vOp1, vOp2;
    int hr1, hr2, vr1, vr2;
    String hOp3, vOp3;
    int hr3, vr3;

    while (true) {
      a = rng.nextInt(maxVal - 1) + 1;
      b = rng.nextInt(maxVal - 1) + 1;
      c = rng.nextInt(maxVal - 1) + 1;
      d = rng.nextInt(maxVal - 1) + 1;

      // Horizontal 
      hOp1 = _randomOp(rng);
      hOp2 = _randomOp(rng);

      // Vertical 
      vOp1 = _randomOp(rng);
      vOp2 = _randomOp(rng);

      // horizontal results
      final hr1n = _compute(a, b, hOp1);
      final hr2n = _compute(c, d, hOp2);
      if (hr1n == null || hr2n == null) continue;
      hr1 = hr1n;
      hr2 = hr2n;

      // vertical results
      final vr1n = _compute(a, c, vOp1);
      final vr2n = _compute(b, d, vOp2);
      if (vr1n == null || vr2n == null) continue;
      vr1 = vr1n;
      vr2 = vr2n;

      // horizontal = hr1 op hr2, vertical = vr1 op vr2
      // result row/col
      hOp3 = _randomOp(rng);
      vOp3 = _randomOp(rng);

      final hr3n = _compute(vr1, vr2, hOp3);
      final vr3n = _compute(hr1, hr2, vOp3);
      if (hr3n == null || vr3n == null) continue;
      hr3 = hr3n;
      vr3 = vr3n;

      if (hr3 != vr3) continue;

      if ([a, b, c, d, hr1, hr2, hr3, vr1, vr2, vr3].any((v) => v.abs() > 999)) continue;

      break;
    }

    // 5x5 grid (numbers + operators)
    // Row 0: a  hOp1  b   =  hr1
    // Row 1: vOp1  .  vOp2  .  vOp3
    // Row 2: c  hOp2  d   =  hr2
    // Row 3: =   .    =   .   =
    // Row 4: vr1 hOp3 vr2  = hr3
    final grid = <List<CrossMathCell>>[];

    final numberValues = [a, b, hr1, c, d, hr2, vr1, vr2, hr3];

    final hideable = <int>[0, 1, 3, 4]; // a, b, c, d indices
    final resultIndices = <int>[2, 5, 6, 7, 8]; // hr1, hr2, vr1, vr2, hr3

    final allHideable = [...hideable];
    if (difficulty == Difficulty.hard || difficulty == Difficulty.expert) {
      allHideable.addAll(resultIndices.sublist(0, 3));
    }

    final numToHide = (allHideable.length * hiddenRatio).ceil().clamp(1, allHideable.length);
    allHideable.shuffle(rng);
    final hiddenIndices = allHideable.sublist(0, numToHide).toSet();

    // Row 0
    grid.add([
      CrossMathCell(type: CellType.number, value: numberValues[0], isHidden: hiddenIndices.contains(0)),
      CrossMathCell(type: CellType.operatorCell, operator: hOp1),
      CrossMathCell(type: CellType.number, value: numberValues[1], isHidden: hiddenIndices.contains(1)),
      CrossMathCell(type: CellType.equals),
      CrossMathCell(type: CellType.number, value: numberValues[2], isHidden: hiddenIndices.contains(2)),
    ]);

    // Row 1: operators
    grid.add([
      CrossMathCell(type: CellType.operatorCell, operator: vOp1),
      CrossMathCell(type: CellType.empty),
      CrossMathCell(type: CellType.operatorCell, operator: vOp2),
      CrossMathCell(type: CellType.empty),
      CrossMathCell(type: CellType.operatorCell, operator: vOp3),
    ]);

    // Row 2
    grid.add([
      CrossMathCell(type: CellType.number, value: numberValues[3], isHidden: hiddenIndices.contains(3)),
      CrossMathCell(type: CellType.operatorCell, operator: hOp2),
      CrossMathCell(type: CellType.number, value: numberValues[4], isHidden: hiddenIndices.contains(4)),
      CrossMathCell(type: CellType.equals),
      CrossMathCell(type: CellType.number, value: numberValues[5], isHidden: hiddenIndices.contains(5)),
    ]);

    // Row 3: equals
    grid.add([
      CrossMathCell(type: CellType.equals),
      CrossMathCell(type: CellType.empty),
      CrossMathCell(type: CellType.equals),
      CrossMathCell(type: CellType.empty),
      CrossMathCell(type: CellType.equals),
    ]);

    // Row 4: results
    grid.add([
      CrossMathCell(type: CellType.number, value: numberValues[6], isHidden: hiddenIndices.contains(6)),
      CrossMathCell(type: CellType.operatorCell, operator: hOp3),
      CrossMathCell(type: CellType.number, value: numberValues[7], isHidden: hiddenIndices.contains(7)),
      CrossMathCell(type: CellType.equals),
      CrossMathCell(type: CellType.number, value: numberValues[8], isHidden: hiddenIndices.contains(8)),
    ]);

    return CrossMathModel(grid: grid, rows: 5, cols: 5);
  }

  static String _randomOp(Random rng) {
    const ops = ['+', '-', '\u00d7'];
    return ops[rng.nextInt(ops.length)];
  }

  static int? _compute(int a, int b, String op) {
    return switch (op) {
      '+' => a + b,
      '-' => a - b,
      '\u00d7' => a * b,
      _ => null,
    };
  }
}
