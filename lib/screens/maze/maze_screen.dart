import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic.dart';
import '../../models/difficulty.dart';
import '../../models/maze_model.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_timer.dart';

class MazeScreen extends StatefulWidget {
  const MazeScreen({super.key});

  @override
  State<MazeScreen> createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen> {
  Difficulty _difficulty = Difficulty.easy;
  late MazeModel _maze;
  bool _isComplete = false;
  int _moves = 0;
  Offset _dragAccum = Offset.zero;
  final _timerKey = GlobalKey<GameTimerState>();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame({Difficulty? difficulty}) {
    setState(() {
      if (difficulty != null) _difficulty = difficulty;
      _maze = MazeModel.generate(_difficulty);
      _isComplete = false;
      _moves = 0;
      _dragAccum = Offset.zero;
    });
    _timerKey.currentState?.reset();
  }

  void _onPanUpdate(DragUpdateDetails details, double cellSize) {
    if (_isComplete) return;
    _dragAccum += details.delta;
    final threshold = cellSize * 0.5;

    while (_dragAccum.dx.abs() >= threshold ||
        _dragAccum.dy.abs() >= threshold) {
      int dc = 0;
      int dr = 0;
      if (_dragAccum.dx.abs() >= _dragAccum.dy.abs()) {
        dc = _dragAccum.dx > 0 ? 1 : -1;
      } else {
        dr = _dragAccum.dy > 0 ? 1 : -1;
      }

      if (_maze.canMove(dc, dr)) {
        setState(() {
          _maze.move(dc, dr);
          _moves++;
        });
        Haptic.selection();
        final oldDx = _dragAccum.dx;
        final oldDy = _dragAccum.dy;
        double newDx = oldDx - dc * cellSize;
        double newDy = oldDy - dr * cellSize;
        if (dc != 0 && newDx.sign != oldDx.sign) newDx = 0;
        if (dr != 0 && newDy.sign != oldDy.sign) newDy = 0;
        _dragAccum = Offset(newDx, newDy);
        if (_maze.isComplete) {
          setState(() => _isComplete = true);
          Haptic.medium();
          _dragAccum = Offset.zero;
          return;
        }
      } else {
        if (dc != 0) {
          _dragAccum = Offset(
            _dragAccum.dx.sign * (threshold - 1),
            _dragAccum.dy,
          );
        } else {
          _dragAccum = Offset(
            _dragAccum.dx,
            _dragAccum.dy.sign * (threshold - 1),
          );
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maze'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _newGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DifficultySelector(
                selected: _difficulty,
                onChanged: (d) => _newGame(difficulty: d),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_moves moves',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  GameTimer(key: _timerKey, isRunning: !_isComplete),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    final cellSize = size / _maze.cols;
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (d) => _onPanUpdate(d, cellSize),
                          onPanEnd: (_) => _dragAccum = Offset.zero,
                          onPanCancel: () => _dragAccum = Offset.zero,
                          child: CustomPaint(
                            painter: _MazePainter(
                              maze: _maze,
                              cellSize: cellSize,
                              playerCol: _maze.playerCol,
                              playerRow: _maze.playerRow,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_isComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Maze Solved!',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MazePainter extends CustomPainter {
  final MazeModel maze;
  final double cellSize;
  final int playerCol;
  final int playerRow;

  _MazePainter({
    required this.maze,
    required this.cellSize,
    required this.playerCol,
    required this.playerRow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = AppTheme.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final goalPaint = Paint()..color = AppTheme.success.withValues(alpha: 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (maze.cols - 1) * cellSize + 2,
          (maze.rows - 1) * cellSize + 2,
          cellSize - 4,
          cellSize - 4,
        ),
        const Radius.circular(4),
      ),
      goalPaint,
    );

    for (int r = 0; r < maze.rows; r++) {
      for (int c = 0; c < maze.cols; c++) {
        final cell = maze.grid[r][c];
        final x = c * cellSize;
        final y = r * cellSize;
        if (cell.top) {
          canvas.drawLine(Offset(x, y), Offset(x + cellSize, y), wallPaint);
        }
        if (cell.left) {
          canvas.drawLine(Offset(x, y), Offset(x, y + cellSize), wallPaint);
        }
        if (c == maze.cols - 1 && cell.right) {
          canvas.drawLine(
            Offset(x + cellSize, y),
            Offset(x + cellSize, y + cellSize),
            wallPaint,
          );
        }
        if (r == maze.rows - 1 && cell.bottom) {
          canvas.drawLine(
            Offset(x, y + cellSize),
            Offset(x + cellSize, y + cellSize),
            wallPaint,
          );
        }
      }
    }

    final playerPaint = Paint()..color = AppTheme.black;
    canvas.drawCircle(
      Offset(
        maze.playerCol * cellSize + cellSize / 2,
        maze.playerRow * cellSize + cellSize / 2,
      ),
      cellSize * 0.3,
      playerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MazePainter oldDelegate) =>
      oldDelegate.maze != maze ||
      oldDelegate.cellSize != cellSize ||
      oldDelegate.playerCol != playerCol ||
      oldDelegate.playerRow != playerRow;
}
