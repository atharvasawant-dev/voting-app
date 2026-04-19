import 'package:flutter/material.dart';

class AnimatedVoteBar extends StatelessWidget {
  const AnimatedVoteBar({
    super.key,
    required this.label,
    required this.votes,
    required this.percentage,
    required this.color,
  });

  final String label;
  final int votes;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = percentage.clamp(0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF12385F),
                ),
              ),
            ),
            Text(
              '$votes votes',
              style: const TextStyle(
                color: Color(0xFF62778D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${(normalized * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 14,
            color: const Color(0xFFE8F0F8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: normalized.toDouble()),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.75), color],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
