import 'package:flutter/material.dart';

import '../main.dart';

class AlreadyVotedScreen extends StatelessWidget {
  const AlreadyVotedScreen({super.key, this.electionTitle});

  final String? electionTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF3E8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC9792A).withOpacity(0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFFC9792A),
                    size: 62,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Already Voted',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0C2A4A),
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  electionTitle == null
                      ? 'This device has already submitted a vote for this election.'
                      : 'This device has already submitted a vote for "$electionTitle".',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF617589),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Votes are final and cannot be changed after submission.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7A8DA1),
                      ),
                ),
                const SizedBox(height: 28),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
