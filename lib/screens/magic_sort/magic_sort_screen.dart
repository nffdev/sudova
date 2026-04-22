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

class _MagicSortScreenState extends State<MagicSortScreen>
    with SingleTickerProviderStateMixin {
  Difficulty _difficulty = Difficulty.easy;
  late MagicSortModel _game;
  int? _selectedBottle;
  bool _isComplete = false;
  final _timerKey = GlobalKey<GameTimerState>();

  late AnimationController _pourController;
  int? _pourFrom;
  int? _pourTo;
  int? _pourColor;
  int _pourCount = 0;

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
    _pourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _newGame();
  }

  @override
  void dispose() {
    _pourController.dispose();
    super.dispose();
  }

  void _newGame() {
    _pourController.reset();
    setState(() {
      _game = MagicSortModel.generate(_difficulty);
      _selectedBottle = null;
      _isComplete = false;
      _pourFrom = null;
      _pourTo = null;
      _pourColor = null;
      _pourCount = 0;
    });
    _timerKey.currentState?.reset();
  }

  bool get _isPouring => _pourController.isAnimating;

  Future<void> _onBottleTap(int index) async {
    if (_isComplete || _isPouring) return;
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
      await _performPour(_selectedBottle!, index);
    } else {
      Haptic.selection();
      setState(() => _selectedBottle = index);
    }
  }

  Future<void> _performPour(int from, int to) async {
    final color = _game.bottles[from].last;
    final count = _computePourCount(from, to);
    Haptic.light();

    setState(() {
      _pourFrom = from;
      _pourTo = to;
      _pourColor = color;
      _pourCount = count;
      _selectedBottle = null;
    });

    await _pourController.forward(from: 0);

    setState(() {
      _game.pour(from, to);
      _pourFrom = null;
      _pourTo = null;
      _pourColor = null;
      _pourCount = 0;
      if (_game.isComplete) {
        _isComplete = true;
        Haptic.medium();
      }
    });
  }

  int _computePourCount(int from, int to) {
    if (_game.bottles[from].isEmpty) return 0;
    final topColor = _game.bottles[from].last;
    int count = 0;
    int i = _game.bottles[from].length - 1;
    while (i >= 0 &&
        _game.bottles[from][i] == topColor &&
        _game.bottles[to].length + count < _game.capacity) {
      count++;
      i--;
    }
    return count;
  }

  void _undo() {
    if (!_game.canUndo || _isPouring) return;
    Haptic.light();
    setState(() {
      _game.undo();
      _selectedBottle = null;
    });
  }

  List<int> _visibleBottle(int index) {
    final current = List<int>.from(_game.bottles[index]);
    if (!_isPouring || _pourFrom == null) return current;

    final t = _pourController.value;
    int transferred;
    if (t <= 0.3) {
      transferred = 0;
    } else if (t >= 0.7) {
      transferred = _pourCount;
    } else {
      transferred = (((t - 0.3) / 0.4) * _pourCount).floor();
    }

    if (index == _pourFrom) {
      for (int i = 0; i < transferred && current.isNotEmpty; i++) {
        current.removeLast();
      }
    } else if (index == _pourTo) {
      for (int i = 0; i < transferred; i++) {
        current.add(_pourColor!);
      }
    }
    return current;
  }

  double _tiltAmount(int index) {
    if (!_isPouring || index != _pourFrom) return 0;
    final t = _pourController.value;
    if (t < 0.3) return t / 0.3;
    if (t > 0.7) return (1.0 - t) / 0.3;
    return 1.0;
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
                child: AnimatedBuilder(
                  animation: _pourController,
                  builder: (context, _) => _buildBottleGrid(),
                ),
              ),
            ),
            if (_isComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
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
    final bottle = _visibleBottle(index);
    final isSelected = _selectedBottle == index;
    final isSource = _pourFrom == index && _isPouring;
    final tilt = _tiltAmount(index);

    final raise = isSelected ? -10.0 : 0.0;
    final extraRaise = isSource ? -22.0 * tilt : 0.0;
    final targetIsRight = isSource && (_pourTo ?? 0) > _pourFrom!;
    final rotation =
        isSource ? (targetIsRight ? 0.45 : -0.45) * tilt : 0.0;
    final pivot = isSource
        ? (targetIsRight ? Alignment.bottomLeft : Alignment.bottomRight)
        : Alignment.bottomCenter;

    return GestureDetector(
      onTap: () => _onBottleTap(index),
      child: Transform.translate(
        offset: Offset(0, raise + extraRaise),
        child: Transform.rotate(
          angle: rotation,
          alignment: pivot,
          child: AspectRatio(
            aspectRatio: 0.35,
            child: _bottleBody(bottle, isSelected),
          ),
        ),
      ),
    );
  }

  Widget _bottleBody(List<int> bottle, bool isSelected) {
    return Container(
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Liquid stack
            Column(
              children: [
                Expanded(
                  flex: (_game.capacity - bottle.length).clamp(0, _game.capacity),
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
            // Glass highlight
            Positioned(
              left: 3,
              top: 4,
              bottom: 4,
              width: 3,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            // Subtle inner shadow on right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
