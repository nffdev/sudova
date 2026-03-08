import 'dart:math';
import 'difficulty.dart';

class SudokuModel {
  final List<List<int>> solution;
  final List<List<int>> puzzle;
  final List<List<bool>> fixed;
  final List<List<bool>> errors;

  SudokuModel({
    required this.solution,
    required this.puzzle,
    required this.fixed,
    required this.errors,
  });

  factory SudokuModel.generate(Difficulty difficulty) {
    final solution = _generateSolution();
    final puzzle = solution.map((r) => List<int>.from(r)).toList();
    final fixed = List.generate(9, (_) => List.filled(9, true));
    final errors = List.generate(9, (_) => List.filled(9, false));

    final cellsToRemove = switch (difficulty) {
      Difficulty.easy => 30,
      Difficulty.medium => 40,
      Difficulty.hard => 50,
      Difficulty.expert => 55,
    };

    final rng = Random();
    var removed = 0;
    while (removed < cellsToRemove) {
      final r = rng.nextInt(9);
      final c = rng.nextInt(9);
      if (puzzle[r][c] != 0) {
        puzzle[r][c] = 0;
        fixed[r][c] = false;
        removed++;
      }
    }

    return SudokuModel(
      solution: solution,
      puzzle: puzzle,
      fixed: fixed,
      errors: errors,
    );
  }

  bool get isComplete {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzle[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  int get emptyCells {
    var count = 0;
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzle[r][c] == 0) count++;
      }
    }
    return count;
  }

  bool setValue(int row, int col, int value) {
    if (fixed[row][col]) return false;
    puzzle[row][col] = value;
    errors[row][col] = value != 0 && value != solution[row][col];
    return true;
  }

  void clear(int row, int col) {
    if (fixed[row][col]) return;
    puzzle[row][col] = 0;
    errors[row][col] = false;
  }

  static List<List<int>> _generateSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  static bool _fillGrid(List<List<int>> grid) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          final numbers = List.generate(9, (i) => i + 1)..shuffle();
          for (final n in numbers) {
            if (_isValid(grid, r, c, n)) {
              grid[r][c] = n;
              if (_fillGrid(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (var i = 0; i < 9; i++) {
      if (grid[row][i] == num || grid[i][col] == num) return false;
    }
    final boxR = (row ~/ 3) * 3;
    final boxC = (col ~/ 3) * 3;
    for (var r = boxR; r < boxR + 3; r++) {
      for (var c = boxC; c < boxC + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }
}
