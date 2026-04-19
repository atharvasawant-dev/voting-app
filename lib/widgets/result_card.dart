import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/candidate_model.dart';
import '../models/election_model.dart';
import '../providers/election_provider.dart';
import 'animated_vote_bar.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.election});

  final ElectionModel election;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ElectionProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3768).withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      election.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0C2A4A),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      election.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF617488),
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ResultsBadge(
                label: election.statusLabel,
                color: election.isActive
                    ? const Color(0xFFEAF8F0)
                    : const Color(0xFFFFF3E8),
                textColor: election.isActive
                    ? const Color(0xFF1F8E5F)
                    : const Color(0xFFC16D20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ResultsBadge(
                label: election.typeLabel,
                color: const Color(0xFFE8F1FC),
                textColor: const Color(0xFF0F4D88),
              ),
              _ResultsBadge(
                label: '${election.totalVotes} total votes',
                color: const Color(0xFFF3F7FA),
                textColor: const Color(0xFF607388),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<CandidateModel>>(
            stream: provider.streamCandidates(election.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final candidates = snapshot.data ?? const <CandidateModel>[];
              if (candidates.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('No candidates available yet.'),
                );
              }

              final totalVotes = candidates.fold<int>(
                0,
                (sum, candidate) => sum + candidate.voteCount,
              );

              return Column(
                children: candidates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final candidate = entry.value;
                  final percentage = totalVotes == 0
                      ? 0.0
                      : candidate.voteCount / totalVotes;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == candidates.length - 1 ? 0 : 16,
                    ),
                    child: AnimatedVoteBar(
                      label: '${candidate.name} • ${candidate.party}',
                      votes: candidate.voteCount,
                      percentage: percentage,
                      color: _palette[index % _palette.length],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  static const _palette = [
    Color(0xFF0D4D89),
    Color(0xFF1E8E5F),
    Color(0xFFC16D20),
    Color(0xFF7A55D1),
  ];
}

class _ResultsBadge extends StatelessWidget {
  const _ResultsBadge({
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
