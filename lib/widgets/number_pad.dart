import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptic.dart';

class NumberPad extends StatelessWidget {
  final void Function(int number) onNumberTap;
  final VoidCallback onDelete;
  final Set<int> disabledNumbers;
  final int maxNumber;

  const NumberPad({
    super.key,
    required this.onNumberTap,
    required this.onDelete,
    this.disabledNumbers = const {},
    this.maxNumber = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            maxNumber > 5 ? 5 : maxNumber,
            (i) => _buildNumberButton(i + 1),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              maxNumber > 5 ? maxNumber - 5 : 0,
              (i) => _buildNumberButton(i + 6),
            ),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    final disabled = disabledNumbers.contains(number);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: disabled
            ? null
            : () {
                Haptic.selection();
                onNumberTap(number);
              },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: disabled ? AppTheme.ultraLightGray : AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: disabled
                  ? AppTheme.ultraLightGray
                  : AppTheme.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: disabled ? AppTheme.lightGray : AppTheme.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () {
          Haptic.light();
          onDelete();
        },
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
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 22,
              color: AppTheme.black,
            ),
          ),
        ),
      ),
    );
  }
}
