import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic.dart';
import '../../models/difficulty.dart';
import '../../models/sudoku_model.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_timer.dart';
import '../../widgets/number_pad.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  Difficulty _difficulty = Difficulty.easy;
  late SudokuModel _game;
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
      _game = SudokuModel.generate(_difficulty);
      _selectedRow = null;
      _selectedCol = null;
      _isComplete = false;
    });
    _timerKey.currentState?.reset();
  }

  void _onCellTap(int row, int col) {
    Haptic.selection();
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _onNumberTap(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_game.fixed[_selectedRow!][_selectedCol!]) return;
    setState(() {
      _game.setValue(_selectedRow!, _selectedCol!, number);
      if (_game.isComplete) {
        _isComplete = true;
        Haptic.medium();
      }
    });
  }

  void _onDelete() {
    if (_selectedRow == null || _selectedCol == null) return;
    setState(() => _game.clear(_selectedRow!, _selectedCol!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
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
                    '${_game.emptyCells} remaining',
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
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
              child: NumberPad(
                onNumberTap: _onNumberTap,
                onDelete: _onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.black, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: List.generate(9, (row) {
            return Expanded(
              child: Row(
                children: List.generate(9, (col) {
                  return Expanded(child: _buildCell(row, col));
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final value = _game.puzzle[row][col];
    final isFixed = _game.fixed[row][col];
    final isSelected = row == _selectedRow && col == _selectedCol;
    final isError = _game.errors[row][col];
    final isSameNumber = value != 0 &&
        _selectedRow != null &&
        _selectedCol != null &&
        _game.puzzle[_selectedRow!][_selectedCol!] == value;
    final isInSelectedRowOrCol =
        row == _selectedRow || col == _selectedCol;
    final isInSelectedBox = _selectedRow != null &&
        _selectedCol != null &&
        (row ~/ 3 == _selectedRow! ~/ 3) &&
        (col ~/ 3 == _selectedCol! ~/ 3);

    Color bgColor = AppTheme.white;
    if (isSelected) {
      bgColor = AppTheme.black;
    } else if (isSameNumber) {
      bgColor = AppTheme.black.withValues(alpha: 0.08);
    } else if (isInSelectedRowOrCol || isInSelectedBox) {
      bgColor = AppTheme.ultraLightGray;
    }

    final rightBorder =
        (col + 1) % 3 == 0 && col != 8 ? 2.0 : 0.5;
    final bottomBorder =
        (row + 1) % 3 == 0 && row != 8 ? 2.0 : 0.5;

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(
              color: AppTheme.black.withValues(
                alpha: rightBorder > 1 ? 1.0 : 0.2,
              ),
              width: rightBorder,
            ),
            bottom: BorderSide(
              color: AppTheme.black.withValues(
                alpha: bottomBorder > 1 ? 1.0 : 0.2,
              ),
              width: bottomBorder,
            ),
          ),
        ),
        child: Center(
          child: value != 0
              ? Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        isFixed ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.white
                        : isError
                            ? AppTheme.error
                            : isFixed
                                ? AppTheme.black
                                : AppTheme.darkGray,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
