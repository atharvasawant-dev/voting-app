import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/election_model.dart';
import '../providers/election_provider.dart';
import '../services/auth_service.dart';
import '../widgets/election_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onElectionTap,
  });

  final ValueChanged<ElectionModel> onElectionTap;

  Future<void> _promptJoinCode(
    BuildContext context,
    ElectionProvider provider,
    ElectionModel election,
  ) async {
    final controller = TextEditingController();

    final enteredCode = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Join Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This election requires an access code before you can vote.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Join Code',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
                autofocus: true,
                onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (enteredCode == null || enteredCode.isEmpty) {
      return;
    }

    if (!provider.validateJoinCode(
      election: election,
      enteredCode: enteredCode,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid join code. Contact your administrator.'),
        ),
      );
      return;
    }

    onElectionTap(election);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final provider = context.watch<ElectionProvider>();
    final currentUser = authService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 1100 ? 40.0 : 20.0;
    final userName = (currentUser?.displayName?.trim().isNotEmpty ?? false)
        ? currentUser!.displayName!.trim()
        : (currentUser?.email?.split('@').first ?? 'Voter');

    return StreamBuilder<List<ElectionModel>>(
      stream: provider.streamElections(),
      builder: (context, snapshot) {
        final elections = snapshot.data ?? const <ElectionModel>[];
        final activeCount = elections.where((election) => election.isActive).length;
        final collegeCount =
            elections.where((election) => election.type == 'college').length;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeAppBar(
                      userName: userName,
                      onLogout: () async {
                        await authService.logout();
                      },
                    ),
                    const SizedBox(height: 18),
                    _HeaderCard(
                      activeCount: activeCount,
                      totalCount: elections.length,
                      collegeCount: collegeCount,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Live Elections',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0C2A4A),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse active campus and local polls, review details, and cast your vote securely.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF5E7288),
                          ),
                    ),
                  ],
                ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.ballot_outlined,
                          size: 68,
                          color:
                              Theme.of(context).colorScheme.primary.withOpacity(0.35),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No elections available yet',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the Admin tab to create an election or load demo data.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xFF61758A)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  28,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final election = elections[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 420 + (index * 120)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, (1 - value) * 28),
                            child: Opacity(
                              opacity: value.clamp(0, 1),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ElectionCard(
                            election: election,
                            onTap: election.isActive
                                ? () => _promptJoinCode(context, provider, election)
                                : null,
                          ),
                        ),
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
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({
    required this.userName,
    required this.onLogout,
  });

  final String userName;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0C3D73),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.how_to_vote_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0C2A4A),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Secure access enabled for your CivicVote account.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF667A8F),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonalIcon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.activeCount,
    required this.totalCount,
    required this.collegeCount,
  });

  final int activeCount;
  final int totalCount;
  final int collegeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3768), Color(0xFF1D5D98)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3768).withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CivicVote',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Secure, real-time digital elections for campuses and communities.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.88),
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
                _MetricChip(label: 'Active', value: '$activeCount'),
                _MetricChip(label: 'Total', value: '$totalCount'),
                _MetricChip(label: 'College', value: '$collegeCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
