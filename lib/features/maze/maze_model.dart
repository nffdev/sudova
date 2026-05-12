import 'dart:math';
import '../../core/difficulty.dart';

typedef _Neighbor = ({int nc, int nr, int side, int opposite});
typedef _FrontierWall = ({int cc, int cr, int side, int nc, int nr, int opposite});

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

  static List<_Neighbor> _neighborsOf(int cc, int cr, int cols, int rows) {
    final list = <_Neighbor>[];
    if (cr > 0) {
      list.add((nc: cc, nr: cr - 1, side: MazeCell.top, opposite: MazeCell.bottom));
    }
    if (cc < cols - 1) {
      list.add((nc: cc + 1, nr: cr, side: MazeCell.right, opposite: MazeCell.left));
    }
    if (cr < rows - 1) {
      list.add((nc: cc, nr: cr + 1, side: MazeCell.bottom, opposite: MazeCell.top));
    }
    if (cc > 0) {
      list.add((nc: cc - 1, nr: cr, side: MazeCell.left, opposite: MazeCell.right));
    }
    return list;
  }

  static void _carveBacktracker(
    List<List<MazeCell>> grid,
    int cols,
    int rows,
    Random rng,
  ) {
    final visited = List.generate(rows, (_) => List.filled(cols, false));
    final stack = <(int, int)>[];
    final sc = rng.nextInt(cols);
    final sr = rng.nextInt(rows);
    visited[sr][sc] = true;
    stack.add((sc, sr));

    while (stack.isNotEmpty) {
      final (cc, cr) = stack.last;
      final neighbors = _neighborsOf(cc, cr, cols, rows)
          .where((n) => !visited[n.nr][n.nc])
          .toList();

      if (neighbors.isEmpty) {
        stack.removeLast();
        continue;
      }
      final n = neighbors[rng.nextInt(neighbors.length)];
      grid[cr][cc].knock(n.side);
      grid[n.nr][n.nc].knock(n.opposite);
      visited[n.nr][n.nc] = true;
      stack.add((n.nc, n.nr));
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
    final frontier = <_FrontierWall>[];
    for (final n in _neighborsOf(sc, sr, cols, rows)) {
      frontier.add((cc: sc, cr: sr, side: n.side, nc: n.nc, nr: n.nr, opposite: n.opposite));
    }

    while (frontier.isNotEmpty) {
      final idx = rng.nextInt(frontier.length);
      final last = frontier.length - 1;
      final w = frontier[idx];
      if (idx != last) frontier[idx] = frontier[last];
      frontier.removeLast();
      if (inMaze[w.nr][w.nc]) continue;
      grid[w.cr][w.cc].knock(w.side);
      grid[w.nr][w.nc].knock(w.opposite);
      inMaze[w.nr][w.nc] = true;
      for (final n in _neighborsOf(w.nc, w.nr, cols, rows)) {
        if (!inMaze[n.nr][n.nc]) {
          frontier.add((cc: w.nc, cr: w.nr, side: n.side, nc: n.nc, nr: n.nr, opposite: n.opposite));
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
      final candidates = _neighborsOf(cc, cr, cols, rows)
          .where((n) => cell.has(n.side))
          .toList();
      if (candidates.isEmpty) continue;
      final pick = candidates[rng.nextInt(candidates.length)];
      cell.knock(pick.side);
      grid[pick.nr][pick.nc].knock(pick.opposite);
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
