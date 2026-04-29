import 'dart:math';
import 'difficulty.dart';

class MazeCell {
  bool top = true;
  bool right = true;
  bool bottom = true;
  bool left = true;
}

class MazeModel {
  final int cols;
  final int rows;
  final List<List<MazeCell>> grid;
  int playerCol = 0;
  int playerRow = 0;

  MazeModel._({
    required this.cols,
    required this.rows,
    required this.grid,
  });

  factory MazeModel.generate(Difficulty difficulty) {
    int size;
    switch (difficulty) {
      case Difficulty.easy:
        size = 8;
        break;
      case Difficulty.medium:
        size = 12;
        break;
      case Difficulty.hard:
        size = 16;
        break;
      case Difficulty.expert:
        size = 20;
        break;
    }
    final grid = List.generate(
      size,
      (_) => List.generate(size, (_) => MazeCell()),
    );
    _carve(grid, size, size);
    return MazeModel._(cols: size, rows: size, grid: grid);
  }

  static void _carve(List<List<MazeCell>> grid, int cols, int rows) {
    final visited = List.generate(rows, (_) => List.filled(cols, false));
    final stack = <List<int>>[];
    final rng = Random();
    visited[0][0] = true;
    stack.add([0, 0]);

    while (stack.isNotEmpty) {
      final cur = stack.last;
      final cc = cur[0];
      final cr = cur[1];
      final neighbors = <List<int>>[];
      // [nc, nr, wallFromCurrent (0=top,1=right,2=bottom,3=left), wallFromNeighbor]
      if (cr > 0 && !visited[cr - 1][cc]) neighbors.add([cc, cr - 1, 0, 2]);
      if (cc < cols - 1 && !visited[cr][cc + 1]) {
        neighbors.add([cc + 1, cr, 1, 3]);
      }
      if (cr < rows - 1 && !visited[cr + 1][cc]) {
        neighbors.add([cc, cr + 1, 2, 0]);
      }
      if (cc > 0 && !visited[cr][cc - 1]) neighbors.add([cc - 1, cr, 3, 1]);

      if (neighbors.isEmpty) {
        stack.removeLast();
        continue;
      }
      final n = neighbors[rng.nextInt(neighbors.length)];
      final nc = n[0];
      final nr = n[1];
      _knock(grid[cr][cc], n[2]);
      _knock(grid[nr][nc], n[3]);
      visited[nr][nc] = true;
      stack.add([nc, nr]);
    }
  }

  static void _knock(MazeCell cell, int side) {
    switch (side) {
      case 0:
        cell.top = false;
        break;
      case 1:
        cell.right = false;
        break;
      case 2:
        cell.bottom = false;
        break;
      case 3:
        cell.left = false;
        break;
    }
  }

  bool get isComplete => playerCol == cols - 1 && playerRow == rows - 1;

  bool canMove(int dc, int dr) {
    final cell = grid[playerRow][playerCol];
    if (dc == 1 && dr == 0) return !cell.right;
    if (dc == -1 && dr == 0) return !cell.left;
    if (dc == 0 && dr == 1) return !cell.bottom;
    if (dc == 0 && dr == -1) return !cell.top;
    return false;
  }

  void move(int dc, int dr) {
    if (!canMove(dc, dr)) return;
    playerCol += dc;
    playerRow += dr;
  }
}
