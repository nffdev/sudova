import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) return;
    Haptic.selection();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: _GlassNavBar(currentIndex: _currentIndex, onTap: _onTap),
    );
  }
}

const _kNavItems = [
  (icon: Icons.grid_view_rounded, label: 'Games'),
  (icon: Icons.settings_rounded, label: 'Settings'),
];

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 48,
        right: 48,
        bottom: bottomPadding + 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppTheme.white.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _kNavItems.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      left: currentIndex * itemWidth + itemWidth / 2 - 30,
                      top: 6,
                      bottom: 6,
                      width: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withValues(alpha: 0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_kNavItems.length, (i) {
                        final item = _kNavItems[i];
                        final selected = currentIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppTheme.black
                                    : AppTheme.mediumGray,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: selected ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                    child: Icon(
                                      item.icon,
                                      size: 22,
                                      color: selected
                                          ? AppTheme.black
                                          : AppTheme.mediumGray,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(item.label),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
