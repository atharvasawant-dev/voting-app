import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/election_model.dart';
import '../providers/election_provider.dart';
import '../widgets/result_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 1100 ? 40.0 : 20.0;

    return Consumer<ElectionProvider>(
      builder: (context, provider, _) {
        return StreamBuilder<List<ElectionModel>>(
          stream: provider.streamElections(),
          builder: (context, snapshot) {
            final elections = snapshot.data ?? const <ElectionModel>[];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      12,
                    ),
                    child: _ResultsHero(elections: elections),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (elections.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No election results yet.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ResultCard(election: elections[index]),
                          );
                        },
                        childCount: elections.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ResultsHero extends StatelessWidget {
  const _ResultsHero({required this.elections});

  final List<ElectionModel> elections;

  @override
  Widget build(BuildContext context) {
    final totalVotes = elections.fold<int>(
      0,
      (sum, election) => sum + election.totalVotes,
    );

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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF0D4D89),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Results Dashboard',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Results update in real time as ballots are submitted to Firestore.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF607387),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(label: 'Elections', value: '${elections.length}'),
              _StatPill(label: 'Total Votes', value: '$totalVotes'),
              _StatPill(
                label: 'Active',
                value: '${elections.where((e) => e.isActive).length}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F3765),
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF607489),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
