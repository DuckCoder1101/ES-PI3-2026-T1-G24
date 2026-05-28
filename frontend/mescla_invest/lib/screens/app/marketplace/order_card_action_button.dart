import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isExecuting;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.isExecuting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isExecuting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class AuthorBadge extends StatelessWidget {
  final bool showSwipeHint;

  const AuthorBadge({super.key, required this.showSwipeHint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.verdeMescla.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.verdeMescla.withValues(alpha: 0.4),
            ),
          ),
          child: const Text(
            'Sua ordem',
            style: TextStyle(
              color: AppColors.verdeMescla,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showSwipeHint) ...[const SizedBox(height: 6), const _SwipeHint()],
      ],
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.chevron_left_rounded, color: Colors.white12, size: 14),
        Icon(Icons.chevron_left_rounded, color: Colors.white24, size: 14),
        Icon(Icons.chevron_left_rounded, color: Colors.white38, size: 14),
      ],
    );
  }
}
