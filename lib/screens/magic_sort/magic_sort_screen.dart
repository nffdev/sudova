import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic.dart';
import '../../models/difficulty.dart';
import '../../models/magic_sort_model.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_timer.dart';

class MagicSortScreen extends StatefulWidget {
  const MagicSortScreen({super.key});

  @override
  State<MagicSortScreen> createState() => _MagicSortScreenState();
}

class _MagicSortScreenState extends State<MagicSortScreen> {
  Difficulty _difficulty = Difficulty.easy;
  late MagicSortModel _game;
  int? _selectedBottle;
  bool _isComplete = false;
  final _timerKey = GlobalKey<GameTimerState>();

  static const List<Color> _palette = [
    Color(0xFFE57373), 
    Color(0xFF64B5F6), 
    Color(0xFF81C784), 
    Color(0xFFFFD54F), 
    Color(0xFFBA68C8), 
    Color(0xFFFF8A65), 
    Color(0xFF4DB6AC), 
    Color(0xFFF06292), 
    Color(0xFFA1887F), 
  ];

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _game = MagicSortModel.generate(_difficulty);
      _selectedBottle = null;
      _isComplete = false;
    });
    _timerKey.currentState?.reset();
  }

  void _onBottleTap(int index) {
    if (_isComplete) return;
    if (_selectedBottle == null) {
      if (_game.bottles[index].isEmpty) return;
      Haptic.selection();
      setState(() => _selectedBottle = index);
      return;
    }
    if (_selectedBottle == index) {
      Haptic.selection();
      setState(() => _selectedBottle = null);
      return;
    }
    if (_game.canPour(_selectedBottle!, index)) {
      Haptic.light();
      setState(() {
        _game.pour(_selectedBottle!, index);
        _selectedBottle = null;
        if (_game.isComplete) {
          _isComplete = true;
          Haptic.medium();
        }
      });
    } else {
      Haptic.selection();
      setState(() => _selectedBottle = index);
    }
  }

  void _undo() {
    if (!_game.canUndo) return;
    Haptic.light();
    setState(() {
      _game.undo();
      _selectedBottle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magic Sort'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            onPressed: _game.canUndo ? _undo : null,
          ),
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
                    '${_game.moves} moves',
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
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildBottleGrid(),
              ),
            ),
            if (_isComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
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
              )
            else
              const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleGrid() {
    final count = _game.bottles.length;
    final cols = count <= 5
        ? count
        : count <= 8
            ? 4
            : (count / 2).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 16,
            children: List.generate(count, (i) {
              final width =
                  (constraints.maxWidth - (cols - 1) * 14) / cols - 2;
              return SizedBox(
                width: width.clamp(40.0, 64.0),
                child: _buildBottle(i),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildBottle(int index) {
    final bottle = _game.bottles[index];
    final isSelected = _selectedBottle == index;

    return GestureDetector(
      onTap: () => _onBottleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
        child: AspectRatio(
          aspectRatio: 0.35,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.black
                    : AppTheme.lightGray.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Expanded(
                    flex: _game.capacity - bottle.length,
                    child: Container(color: AppTheme.white),
                  ),
                  ...bottle.reversed.map(
                    (c) => Expanded(
                      flex: 1,
                      child: Container(color: _palette[c]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
