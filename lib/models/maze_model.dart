import 'dart:math';
import 'difficulty.dart';

class MazeCell {
  static const int top = 1 << 0;
  static const int right = 1 << 1;
  static const int bottom = 1 << 2;
  static const int left = 1 << 3;
  static const int all = top | right | bottom | left;

  int walls = all;

  bool has(int side) => (walls & side) != 0;
  void knock(int side) => walls &= ~side;
}

class MazeModel {
  final int cols;
  final int rows;
  final List<List<MazeCell>> grid;
  int playerCol = 0;
  int playerRow = 0;
  int version = 0;

  MazeModel._({
    required this.cols,
    required this.rows,
    required this.grid,
  });

  static const Map<Difficulty, int> _sizeByDifficulty = {
    Difficulty.easy: 8,
    Difficulty.medium: 12,
    Difficulty.hard: 16,
    Difficulty.expert: 20,
  };
  static const double _loopRatio = 0.04;

  factory MazeModel.generate(Difficulty difficulty) {
    final size = _sizeByDifficulty[difficulty]!;
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
    if (cr > 0) list.add([cc, cr - 1, MazeCell.top, MazeCell.bottom]);
    if (cc < cols - 1) {
      list.add([cc + 1, cr, MazeCell.right, MazeCell.left]);
    }
    if (cr < rows - 1) {
      list.add([cc, cr + 1, MazeCell.bottom, MazeCell.top]);
    }
    if (cc > 0) list.add([cc - 1, cr, MazeCell.left, MazeCell.right]);
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
      grid[cr][cc].knock(n[2]);
      grid[n[1]][n[0]].knock(n[3]);
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
      final last = frontier.length - 1;
      final w = frontier[idx];
      if (idx != last) frontier[idx] = frontier[last];
      frontier.removeLast();
      final cc = w[0], cr = w[1], nc = w[3], nr = w[4];
      if (inMaze[nr][nc]) continue;
      grid[cr][cc].knock(w[2]);
      grid[nr][nc].knock(w[5]);
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
    final extra = ((cols * rows) * _loopRatio).round();
    for (int i = 0; i < extra; i++) {
      final cc = rng.nextInt(cols);
      final cr = rng.nextInt(rows);
      final cell = grid[cr][cc];
      final candidates = <List<int>>[];
      if (cr > 0 && cell.has(MazeCell.top)) {
        candidates.add([MazeCell.top, cc, cr - 1, MazeCell.bottom]);
      }
      if (cc < cols - 1 && cell.has(MazeCell.right)) {
        candidates.add([MazeCell.right, cc + 1, cr, MazeCell.left]);
      }
      if (cr < rows - 1 && cell.has(MazeCell.bottom)) {
        candidates.add([MazeCell.bottom, cc, cr + 1, MazeCell.top]);
      }
      if (cc > 0 && cell.has(MazeCell.left)) {
        candidates.add([MazeCell.left, cc - 1, cr, MazeCell.right]);
      }
      if (candidates.isEmpty) continue;
      final pick = candidates[rng.nextInt(candidates.length)];
      cell.knock(pick[0]);
      grid[pick[2]][pick[1]].knock(pick[3]);
    }
  }

  bool get isComplete => playerCol == cols - 1 && playerRow == rows - 1;

  bool canMove(int dc, int dr) {
    final cell = grid[playerRow][playerCol];
    if (dc == 1 && dr == 0) return !cell.has(MazeCell.right);
    if (dc == -1 && dr == 0) return !cell.has(MazeCell.left);
    if (dc == 0 && dr == 1) return !cell.has(MazeCell.bottom);
    if (dc == 0 && dr == -1) return !cell.has(MazeCell.top);
    return false;
  }

  void move(int dc, int dr) {
    if (!canMove(dc, dr)) return;
    playerCol += dc;
    playerRow += dr;
    version++;
  }
}
