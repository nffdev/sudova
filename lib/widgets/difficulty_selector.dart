import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptic.dart';
import '../models/difficulty.dart';

class DifficultySelector extends StatelessWidget {
  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;

  const DifficultySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.ultraLightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: Difficulty.values.map((d) {
          final isSelected = d == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                Haptic.selection();
                onChanged(d);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    d.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppTheme.white : AppTheme.mediumGray,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
