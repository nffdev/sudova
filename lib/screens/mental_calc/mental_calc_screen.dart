import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic.dart';
import '../../models/difficulty.dart';
import '../../models/mental_calc_model.dart';
import '../../widgets/difficulty_selector.dart';

class MentalCalcScreen extends StatefulWidget {
  const MentalCalcScreen({super.key});

  @override
  State<MentalCalcScreen> createState() => _MentalCalcScreenState();
}

class _MentalCalcScreenState extends State<MentalCalcScreen>
    with SingleTickerProviderStateMixin {
  Difficulty _difficulty = Difficulty.easy;
  late MentalCalcProblem _problem;
  String _input = '';
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool? _lastResult;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _nextProblem();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _nextProblem() {
    setState(() {
      _problem = MentalCalcProblem.generate(_difficulty);
      _input = '';
      _lastResult = null;
    });
  }

  void _onNumberTap(int n) {
    Haptic.selection();
    setState(() {
      if (_input.length < 6) _input += '$n';
    });
  }

  void _onDelete() {
    Haptic.light();
    if (_input.isNotEmpty) {
      setState(() => _input = _input.substring(0, _input.length - 1));
    }
  }

  void _onSubmit() {
    if (_input.isEmpty) return;
    final parsed = int.tryParse(_input);
    if (parsed == null) return;

    final correct = parsed == _problem.answer;
    setState(() {
      _lastResult = correct;
      if (correct) {
        _score += 10 * (_streak + 1);
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        Haptic.medium();
      } else {
        _streak = 0;
        _shakeController.forward(from: 0);
        Haptic.medium();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _nextProblem();
    });
  }

  void _onNegative() {
    Haptic.selection();
    setState(() {
      if (_input.startsWith('-')) {
        _input = _input.substring(1);
      } else {
        _input = '-$_input';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Calc'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  _score = 0;
                  _streak = 0;
                  _bestStreak = 0;
                  _nextProblem();
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatChip(Icons.star_outline_rounded, '$_score'),
                  _buildStatChip(
                      Icons.local_fire_department_outlined, '$_streak'),
                  _buildStatChip(Icons.emoji_events_outlined, '$_bestStreak'),
                ],
              ),
            ),
            const Spacer(flex: 2),
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final dx = _shakeController.isAnimating
                    ? (4 *
                        (0.5 - _shakeController.value).abs() *
                        (_shakeController.value < 0.5 ? -1 : 1) *
                        8)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    _problem.display,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.black,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _lastResult == null
                              ? AppTheme.black
                              : _lastResult!
                                  ? AppTheme.success
                                  : AppTheme.error,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _input.isEmpty ? '?' : _input,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: _input.isEmpty
                            ? AppTheme.lightGray
                            : _lastResult == null
                                ? AppTheme.black
                                : _lastResult!
                                    ? AppTheme.success
                                    : AppTheme.error,
                      ),
                    ),
                  ),
                  if (_lastResult == false)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '= ${_problem.answer}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppTheme.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _buildCalcPad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.ultraLightGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.mediumGray),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcPad() {
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
            _buildActionKey(
              Icons.backspace_outlined,
              _onDelete,
            ),
            _buildSubmitKey(),
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

  Widget _buildActionKey(IconData icon, VoidCallback onTap) {
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

  Widget _buildSubmitKey() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: _onSubmit,
        child: Container(
          width: 120,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 26,
              color: AppTheme.white,
            ),
          ),
        ),
      ),
    );
  }
}
