import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/game_card.dart';
import '../sudoku/sudoku_screen.dart';
import '../mental_calc/mental_calc_screen.dart';
import '../crossmath/crossmath_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sudova',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Train your brain with puzzles',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.mediumGray,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'GAMES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightGray,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              GameCard(
                title: 'Sudoku',
                subtitle: 'Classic number placement puzzle',
                icon: Icons.grid_on_rounded,
                onTap: () => _navigateTo(context, const SudokuScreen()),
              ),
              const SizedBox(height: 12),
              GameCard(
                title: 'Mental Calc',
                subtitle: 'Speed arithmetic challenges',
                icon: Icons.psychology_outlined,
                onTap: () => _navigateTo(context, const MentalCalcScreen()),
              ),
              const SizedBox(height: 12),
              GameCard(
                title: 'CrossMath',
                subtitle: 'Equation crossword puzzles',
                icon: Icons.calculate_outlined,
                onTap: () => _navigateTo(context, const CrossMathScreen()),
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightGray.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
