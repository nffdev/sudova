import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic.dart';
import '../../models/difficulty.dart';
import '../../models/crossmath_model.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_timer.dart';

class CrossMathScreen extends StatefulWidget {
  const CrossMathScreen({super.key});

  @override
  State<CrossMathScreen> createState() => _CrossMathScreenState();
}

class _CrossMathScreenState extends State<CrossMathScreen> {
  Difficulty _difficulty = Difficulty.easy;
  late CrossMathModel _game;
  int? _selectedRow;
  int? _selectedCol;
  bool _isComplete = false;
  final _timerKey = GlobalKey<GameTimerState>();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _game = CrossMathModel.generate(_difficulty);
      _selectedRow = null;
      _selectedCol = null;
      _isComplete = false;
    });
    _timerKey.currentState?.reset();
  }

  void _onCellTap(int row, int col) {
    final cell = _game.grid[row][col];
    if (cell.type != CellType.number || !cell.isHidden) return;
    Haptic.selection();
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _onNumberTap(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    final cell = _game.grid[_selectedRow!][_selectedCol!];
    if (!cell.isHidden) return;

    setState(() {
      if (cell.userValue != null && cell.userValue!.abs() < 100) {
        final extended = cell.userValue! * 10 + (cell.userValue!.isNegative ? -number : number);
        if (extended.abs() <= 999) {
          cell.userValue = extended;
        }
      } else {
        cell.userValue = number;
      }

      if (_game.isComplete) {
        _isComplete = true;
        Haptic.medium();
      }
    });
  }

  void _onDelete() {
    if (_selectedRow == null || _selectedCol == null) return;
    final cell = _game.grid[_selectedRow!][_selectedCol!];
    if (!cell.isHidden) return;
    Haptic.light();
    setState(() {
      if (cell.userValue != null && cell.userValue!.abs() >= 10) {
        cell.userValue = cell.userValue! ~/ 10;
        if (cell.userValue == 0) cell.userValue = null;
      } else {
        cell.userValue = null;
      }
    });
  }

  void _onNegative() {
    if (_selectedRow == null || _selectedCol == null) return;
    final cell = _game.grid[_selectedRow!][_selectedCol!];
    if (!cell.isHidden || cell.userValue == null) return;
    Haptic.selection();
    setState(() {
      cell.userValue = -cell.userValue!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CrossMath'),
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
                onChanged: (d) {
                  _difficulty = d;
                  _newGame();
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_game.hiddenCount} remaining',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  GameTimer(
                    key: _timerKey,
                    isRunning: !_isComplete,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildGrid(),
                ),
              ),
            ),
            if (_isComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Puzzle Complete!',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _buildInputPad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    // 3 number cols + 2 operator cols (0.5x) = 4 units wide
    // 3 number rows + 2 operator rows (0.5x) = 4 units tall
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.maxWidth.clamp(0.0, 340.0);
        final unit = maxSize / 4;
        final cellSize = unit;
        final opSize = unit * 0.5;
        final totalW = cellSize * 3 + opSize * 2;
        final totalH = cellSize * 3 + opSize * 2;

        return Center(
          child: SizedBox(
            width: totalW,
            height: totalH,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_game.rows, (row) {
                final isOpRow = row == 1 || row == 3;
                return SizedBox(
                  height: isOpRow ? opSize : cellSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_game.cols, (col) {
                      final isOpCol = col == 1 || col == 3;
                      return SizedBox(
                        width: isOpCol ? opSize : cellSize,
                        child: _buildCell(row, col),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int row, int col) {
    final cell = _game.grid[row][col];

    if (cell.type == CellType.empty) {
      return const SizedBox.expand();
    }

    if (cell.type == CellType.operatorCell || cell.type == CellType.equals) {
      return Center(
        child: Text(
          cell.display,
          style: TextStyle(
            fontSize: cell.type == CellType.equals ? 20 : 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.mediumGray,
          ),
        ),
      );
    }

    final isSelected = row == _selectedRow && col == _selectedCol;
    final isHidden = cell.isHidden;
    final hasValue = cell.userValue != null;
    final isCorrect = cell.isCorrect;
    final hasError = isHidden && hasValue && !isCorrect;

    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      bgColor = AppTheme.black;
      textColor = AppTheme.white;
      borderColor = AppTheme.black;
    } else if (isHidden && !hasValue) {
      bgColor = AppTheme.ultraLightGray;
      textColor = AppTheme.lightGray;
      borderColor = AppTheme.lightGray.withValues(alpha: 0.5);
    } else if (hasError) {
      bgColor = AppTheme.white;
      textColor = AppTheme.error;
      borderColor = AppTheme.error.withValues(alpha: 0.4);
    } else if (isHidden && isCorrect) {
      bgColor = AppTheme.white;
      textColor = AppTheme.success;
      borderColor = AppTheme.success.withValues(alpha: 0.4);
    } else {
      bgColor = AppTheme.white;
      textColor = AppTheme.black;
      borderColor = AppTheme.black.withValues(alpha: 0.15);
    }

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            cell.display,
            style: TextStyle(
              fontSize: 22,
              fontWeight: isHidden ? FontWeight.w500 : FontWeight.w700,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++) _buildKey('$i', () => _onNumberTap(i)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 6; i <= 9; i++) _buildKey('$i', () => _onNumberTap(i)),
            _buildKey('0', () => _onNumberTap(0)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('\u00b1', _onNegative),
            _buildIconKey(Icons.backspace_outlined, _onDelete),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconKey(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(icon, size: 22, color: AppTheme.black),
          ),
        ),
      ),
    );
  }
}
