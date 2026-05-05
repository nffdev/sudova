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
    final rng = Random();
    if (rng.nextBool()) {
      _carveBacktracker(grid, size, size, rng);
    } else {
      _carvePrim(grid, size, size, rng);
    }
    _addLoops(grid, size, size, rng);
    return MazeModel._(cols: size, rows: size, grid: grid);
  }

  static List<List<int>> _neighborsOf(int cc, int cr, int cols, int rows) {
    final list = <List<int>>[];
    if (cr > 0) list.add([cc, cr - 1, 0, 2]);
    if (cc < cols - 1) list.add([cc + 1, cr, 1, 3]);
    if (cr < rows - 1) list.add([cc, cr + 1, 2, 0]);
    if (cc > 0) list.add([cc - 1, cr, 3, 1]);
    return list;
  }

  static void _carveBacktracker(
    List<List<MazeCell>> grid,
    int cols,
    int rows,
    Random rng,
  ) {
    final visited = List.generate(rows, (_) => List.filled(cols, false));
    final stack = <List<int>>[];
    final sc = rng.nextInt(cols);
    final sr = rng.nextInt(rows);
    visited[sr][sc] = true;
    stack.add([sc, sr]);

    while (stack.isNotEmpty) {
      final cur = stack.last;
      final cc = cur[0];
      final cr = cur[1];
      final neighbors = _neighborsOf(cc, cr, cols, rows)
          .where((n) => !visited[n[1]][n[0]])
          .toList();

      if (neighbors.isEmpty) {
        stack.removeLast();
        continue;
      }
      final n = neighbors[rng.nextInt(neighbors.length)];
      _knock(grid[cr][cc], n[2]);
      _knock(grid[n[1]][n[0]], n[3]);
      visited[n[1]][n[0]] = true;
      stack.add([n[0], n[1]]);
    }
  }

  static void _carvePrim(
    List<List<MazeCell>> grid,
    int cols,
    int rows,
    Random rng,
  ) {
    final inMaze = List.generate(rows, (_) => List.filled(cols, false));
    final sc = rng.nextInt(cols);
    final sr = rng.nextInt(rows);
    inMaze[sr][sc] = true;
    // frontier walls: [cc, cr, wallSide, nc, nr, neighborSide]
    final frontier = <List<int>>[];
    for (final n in _neighborsOf(sc, sr, cols, rows)) {
      frontier.add([sc, sr, n[2], n[0], n[1], n[3]]);
    }

    while (frontier.isNotEmpty) {
      final idx = rng.nextInt(frontier.length);
      final w = frontier.removeAt(idx);
      final cc = w[0], cr = w[1], nc = w[3], nr = w[4];
      if (inMaze[nr][nc]) continue;
      _knock(grid[cr][cc], w[2]);
      _knock(grid[nr][nc], w[5]);
      inMaze[nr][nc] = true;
      for (final n in _neighborsOf(nc, nr, cols, rows)) {
        if (!inMaze[n[1]][n[0]]) {
          frontier.add([nc, nr, n[2], n[0], n[1], n[3]]);
        }
      }
    }
  }

  static void _addLoops(
    List<List<MazeCell>> grid,
    int cols,
    int rows,
    Random rng,
  ) {
    final extra = ((cols * rows) * 0.04).round();
    for (int i = 0; i < extra; i++) {
      final cc = rng.nextInt(cols);
      final cr = rng.nextInt(rows);
      final candidates = <List<int>>[];
      if (cr > 0 && grid[cr][cc].top) candidates.add([0, cc, cr - 1, 2]);
      if (cc < cols - 1 && grid[cr][cc].right) {
        candidates.add([1, cc + 1, cr, 3]);
      }
      if (cr < rows - 1 && grid[cr][cc].bottom) {
        candidates.add([2, cc, cr + 1, 0]);
      }
      if (cc > 0 && grid[cr][cc].left) candidates.add([3, cc - 1, cr, 1]);
      if (candidates.isEmpty) continue;
      final pick = candidates[rng.nextInt(candidates.length)];
      _knock(grid[cr][cc], pick[0]);
      _knock(grid[pick[2]][pick[1]], pick[3]);
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
