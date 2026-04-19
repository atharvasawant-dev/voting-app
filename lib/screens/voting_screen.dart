import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/candidate_model.dart';
import '../models/election_model.dart';
import '../providers/election_provider.dart';
import '../widgets/candidate_tile.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key, required this.election});

  final ElectionModel election;

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  String? _selectedCandidateId;
  late Future<bool> _alreadyVotedFuture;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _alreadyVotedFuture = context.read<ElectionProvider>().hasUserVoted(
          widget.election.id,
        );
  }

  Future<void> _handleVote(ElectionProvider provider) async {
    final selectedCandidateId = _selectedCandidateId;
    if (selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate first.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Vote'),
              content: const Text('Are you sure you want to submit this vote?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm Vote'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await provider.submitVote(
        electionId: widget.election.id,
        candidateId: selectedCandidateId,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.success,
        arguments: widget.election.title,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString();
      if (message.toLowerCase().contains('already voted')) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.alreadyVoted,
          arguments: widget.election.title,
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _goToAlreadyVoted() {
    if (_redirected || !mounted) {
      return;
    }

    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.alreadyVoted,
        arguments: widget.election.title,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ElectionProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 900 ? 880.0 : double.infinity;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: _alreadyVotedFuture,
          builder: (context, votedSnapshot) {
            if (votedSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (votedSnapshot.data == true) {
              _goToAlreadyVoted();
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Cast Your Vote',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0C2A4A),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0D3F73)
                                        .withOpacity(0.08),
                                    blurRadius: 22,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _InfoBadge(
                                        icon: Icons.flag_outlined,
                                        label: widget.election.typeLabel,
                                      ),
                                      _InfoBadge(
                                        icon: widget.election.isActive
                                            ? Icons.bolt
                                            : Icons.lock_clock,
                                        label: widget.election.statusLabel,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.election.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.election.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: const Color(0xFF5B7086),
                                          height: 1.5,
                                        ),
                                  ),
                                  if (!widget.election.isActive) ...[
                                    const SizedBox(height: 18),
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E8),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Color(0xFFC16C1A),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'This election is closed. You can review candidates, but voting is disabled.',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Select a Candidate',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Choose one option carefully. Votes cannot be changed after submission.',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF63778C),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<List<CandidateModel>>(
                      stream: provider.streamCandidates(widget.election.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        final candidates = snapshot.data ?? const <CandidateModel>[];
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == candidates.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size.fromHeight(58),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      onPressed: widget.election.isActive &&
                                              !provider.isSubmittingVote
                                          ? () => _handleVote(provider)
                                          : null,
                                      icon: provider.isSubmittingVote
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.4,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.verified_outlined),
                                      label: Text(
                                        provider.isSubmittingVote
                                            ? 'Submitting Vote...'
                                            : 'Confirm Vote',
                                      ),
                                    ),
                                  );
                                }

                                final candidate = candidates[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: CandidateTile(
                                    candidate: candidate,
                                    isSelected:
                                        candidate.id == _selectedCandidateId,
                                    onTap: widget.election.isActive
                                        ? () {
                                            setState(() {
                                              _selectedCandidateId = candidate.id;
                                            });
                                          }
                                        : null,
                                  ),
                                );
                              },
                              childCount: candidates.length + 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0F4C86)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F4C86),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
