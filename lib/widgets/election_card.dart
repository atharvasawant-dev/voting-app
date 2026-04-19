import 'package:flutter/material.dart';

import '../models/election_model.dart';

class ElectionCard extends StatelessWidget {
  const ElectionCard({
    super.key,
    required this.election,
    required this.onTap,
  });

  final ElectionModel election;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typeColor = election.isCollege
        ? const Color(0xFF0E5A9C)
        : const Color(0xFF15806B);
    final statusColor =
        election.isActive ? const Color(0xFF1E8E5A) : const Color(0xFFC16D20);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3768).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Tag(
                      label: election.typeLabel,
                      color: typeColor.withOpacity(0.1),
                      textColor: typeColor,
                    ),
                    _Tag(
                      label: election.statusLabel,
                      color: statusColor.withOpacity(0.12),
                      textColor: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  election.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0C2A4A),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  election.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF607387),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _InfoStat(
                      icon: Icons.groups_3_outlined,
                      label: '${election.candidateCount} candidates',
                    ),
                    const SizedBox(width: 14),
                    _InfoStat(
                      icon: Icons.how_to_vote_outlined,
                      label: '${election.totalVotes} votes',
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: onTap == null ? 0.55 : 1,
                      child: FilledButton.tonal(
                        onPressed: onTap,
                        child: Text(onTap == null ? 'Closed' : 'Vote Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6D8093)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6D8093),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
