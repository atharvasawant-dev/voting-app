import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/candidate_model.dart';
import '../models/election_model.dart';
import '../providers/election_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _passwordController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _joinCodeController = TextEditingController();
  final List<_CandidateFormData> _candidateForms = [];

  bool _isUnlocked = false;
  String _type = 'college';

  @override
  void initState() {
    super.initState();
    _setDefaultCandidates();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _joinCodeController.dispose();
    for (final form in _candidateForms) {
      form.dispose();
    }
    super.dispose();
  }

  void _setDefaultCandidates() {
    for (final form in _candidateForms) {
      form.dispose();
    }
    _candidateForms
      ..clear()
      ..addAll([
        _CandidateFormData(),
        _CandidateFormData(),
        _CandidateFormData(),
      ]);
  }

  void _unlockAdmin() {
    if (_passwordController.text.trim() == 'admin123') {
      setState(() => _isUnlocked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin access granted.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect password.')),
    );
  }

  Future<void> _createElection(ElectionProvider provider) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final joinCode = _joinCodeController.text.trim();
    final candidates = _candidateForms
        .map(
          (form) => CandidateModel(
            id: '',
            name: form.nameController.text.trim(),
            position: form.positionController.text.trim(),
            party: form.partyController.text.trim(),
            voteCount: 0,
          ),
        )
        .where(
          (candidate) =>
              candidate.name.isNotEmpty &&
              candidate.position.isNotEmpty &&
              candidate.party.isNotEmpty,
        )
        .toList();

    if (title.isEmpty ||
        description.isEmpty ||
        joinCode.isEmpty ||
        candidates.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add a title, description, join code, and at least two complete candidates.',
          ),
        ),
      );
      return;
    }

    try {
      await provider.createElection(
        title: title,
        description: description,
        type: _type,
        joinCode: joinCode,
        candidates: candidates,
      );

      _titleController.clear();
      _descriptionController.clear();
      _joinCodeController.clear();
      setState(() {
        _type = 'college';
        _setDefaultCandidates();
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Election created successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _loadCandidateTemplate() {
    final template = _type == 'college'
        ? const [
            ('Aarav Mehta', 'President', 'Campus Forward'),
            ('Riya Kapoor', 'President', 'Student Voice'),
            ('Kabir Nair', 'President', 'Future Council'),
          ]
        : const [
            ('Neha Sharma', 'Ward Representative', 'People First'),
            ('Vikram Rao', 'Ward Representative', 'Community Alliance'),
            ('Ananya Das', 'Ward Representative', 'Civic Future'),
          ];

    setState(() {
      _joinCodeController.text = 'DEMO2025';
      _setDefaultCandidates();
      for (var index = 0; index < template.length; index++) {
        _candidateForms[index].nameController.text = template[index].$1;
        _candidateForms[index].positionController.text = template[index].$2;
        _candidateForms[index].partyController.text = template[index].$3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ElectionProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 1200 ? 40.0 : 20.0;

    if (!_isUnlocked) {
      return Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B3768).withOpacity(0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FB),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF0C4B86),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Admin Access',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the admin password to create elections, load test data, and manage voting status.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF62778D),
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Admin password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onSubmitted: (_) => _unlockAdmin(),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: _unlockAdmin,
                    icon: const Icon(Icons.login),
                    label: const Text('Unlock Admin Panel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AdminHeader(
                      electionCount: elections.length,
                      totalVotes: elections.fold<int>(
                        0,
                        (sum, election) => sum + election.totalVotes,
                      ),
                      onSeedTap: provider.seedSampleElections,
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Create Election'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: _panelDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Election title',
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description_outlined),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _type,
                            decoration: const InputDecoration(
                              labelText: 'Election type',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'college',
                                child: Text('College'),
                              ),
                              DropdownMenuItem(
                                value: 'local',
                                child: Text('Local'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() => _type = value);
                            },
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _joinCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Join Code',
                              prefixIcon: Icon(Icons.key_outlined),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Candidates',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _loadCandidateTemplate,
                                icon: const Icon(Icons.auto_fix_high_outlined),
                                label: const Text('Load Sample Names'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _candidateForms.add(_CandidateFormData());
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Candidate'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _candidateForms.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final form = _candidateForms[index];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6FAFD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Candidate ${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (_candidateForms.length > 2)
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                final removed =
                                                    _candidateForms.removeAt(index);
                                                removed.dispose();
                                              });
                                            },
                                            icon: const Icon(Icons.delete_outline),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: form.nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Candidate name',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: form.positionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Position',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: form.partyController,
                                      decoration: const InputDecoration(
                                        labelText: 'Party / Class',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                            ),
                            onPressed: provider.isSavingElection
                                ? null
                                : () => _createElection(provider),
                            icon: provider.isSavingElection
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add_card_outlined),
                            label: Text(
                              provider.isSavingElection
                                  ? 'Creating Election...'
                                  : 'Create Election',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(context, 'Manage Elections'),
                  ],
                ),
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  24,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final election = elections[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          decoration: _panelDecoration(),
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: election.isActive
                                      ? const Color(0xFFE9F7F1)
                                      : const Color(0xFFFFF2E8),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  election.isActive
                                      ? Icons.how_to_vote
                                      : Icons.pause_circle_outline,
                                  color: election.isActive
                                      ? const Color(0xFF1F8E5F)
                                      : const Color(0xFFC16D20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      election.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      election.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF617488),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        _MetaChip(
                                          label: election.typeLabel,
                                          color: const Color(0xFFE8F1FC),
                                          textColor: const Color(0xFF0F4D88),
                                        ),
                                        _MetaChip(
                                          label: '${election.totalVotes} votes',
                                          color: const Color(0xFFF1F5F9),
                                          textColor: const Color(0xFF5C7186),
                                        ),
                                        _MetaChip(
                                          label: 'Code: ${election.joinCode}',
                                          color: const Color(0xFFF3EDFf),
                                          textColor: const Color(0xFF5B4AB5),
                                        ),
                                        _MetaChip(
                                          label: election.statusLabel,
                                          color: election.isActive
                                              ? const Color(0xFFE9F7F1)
                                              : const Color(0xFFFFF2E8),
                                          textColor: election.isActive
                                              ? const Color(0xFF1F8E5F)
                                              : const Color(0xFFC16D20),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonal(
                                onPressed: () async {
                                  await provider.toggleElectionStatus(election);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        election.isActive
                                            ? 'Election closed.'
                                            : 'Election reopened.',
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  election.isActive ? 'Close' : 'Open',
                                ),
                              ),
                            ],
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

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0B3768).withOpacity(0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0C2A4A),
          ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.electionCount,
    required this.totalVotes,
    required this.onSeedTap,
  });

  final int electionCount;
  final int totalVotes;
  final Future<void> Function() onSeedTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3768), Color(0xFF1E5D97)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Election Control Center',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create polls, seed demo data, and manage election status from one place.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeaderPill(label: 'Elections', value: '$electionCount'),
              _HeaderPill(label: 'Votes Cast', value: '$totalVotes'),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0B3768),
            ),
            onPressed: () async {
              await onSeedTap();
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sample elections added or refreshed.'),
                ),
              );
            },
            icon: const Icon(Icons.dataset_linked_outlined),
            label: const Text('Create Demo Elections'),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
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

class _CandidateFormData {
  _CandidateFormData()
      : nameController = TextEditingController(),
        positionController = TextEditingController(),
        partyController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController positionController;
  final TextEditingController partyController;

  void dispose() {
    nameController.dispose();
    positionController.dispose();
    partyController.dispose();
  }
}
