import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/candidate_model.dart';
import '../models/election_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ElectionProvider extends ChangeNotifier {
  ElectionProvider({
    required FirestoreService firestoreService,
    required AuthService authService,
  })  : _firestoreService = firestoreService,
        _authService = authService,
        _userId = authService.currentUser?.uid,
        _isReady = true {
    _authSubscription = _authService.authStateChanges().listen(_onAuthChanged);
  }

  final FirestoreService _firestoreService;
  final AuthService _authService;
  late final StreamSubscription<User?> _authSubscription;

  bool _isReady;
  bool _isSubmittingVote = false;
  bool _isSavingElection = false;
  String? _userId;

  bool get isReady => _isReady;
  bool get isSubmittingVote => _isSubmittingVote;
  bool get isSavingElection => _isSavingElection;
  String? get userId => _userId;

  void _onAuthChanged(User? user) {
    _userId = user?.uid;
    _isReady = true;
    notifyListeners();
  }

  Stream<List<ElectionModel>> streamElections() {
    return _firestoreService.streamElections();
  }

  Stream<List<CandidateModel>> streamCandidates(String electionId) {
    return _firestoreService.streamCandidates(electionId);
  }

  bool validateJoinCode({
    required ElectionModel election,
    required String enteredCode,
  }) {
    return election.joinCode.trim() == enteredCode.trim();
  }

  Future<bool> hasUserVoted(String electionId) async {
    final id = _userId;
    if (id == null) {
      return false;
    }
    return _firestoreService.hasUserVoted(
      userId: id,
      electionId: electionId,
    );
  }

  Future<void> syncUserProfile({
    required String name,
    required String email,
  }) async {
    final id = _userId;
    if (id == null) {
      return;
    }

    await _firestoreService.syncUserProfile(
      userId: id,
      name: name,
      email: email,
    );
  }

  Future<void> submitVote({
    required String electionId,
    required String candidateId,
  }) async {
    final id = _userId;
    if (id == null) {
      throw Exception('Please log in to vote.');
    }

    _isSubmittingVote = true;
    notifyListeners();

    try {
      await _firestoreService.castVote(
        userId: id,
        electionId: electionId,
        candidateId: candidateId,
      );
    } finally {
      _isSubmittingVote = false;
      notifyListeners();
    }
  }

  Future<void> createElection({
    required String title,
    required String description,
    required String type,
    required String joinCode,
    required List<CandidateModel> candidates,
  }) async {
    _isSavingElection = true;
    notifyListeners();

    try {
      await _firestoreService.createElection(
        title: title,
        description: description,
        type: type,
        joinCode: joinCode,
        candidates: candidates,
      );
    } finally {
      _isSavingElection = false;
      notifyListeners();
    }
  }

  Future<void> toggleElectionStatus(ElectionModel election) {
    return _firestoreService.updateElectionStatus(
      electionId: election.id,
      status: election.isActive ? 'closed' : 'active',
    );
  }

  Future<void> seedSampleElections() {
    return _firestoreService.seedSampleElections();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
