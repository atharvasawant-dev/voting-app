import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/candidate_model.dart';
import '../models/election_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _elections =>
      _firestore.collection('elections');

  CollectionReference<Map<String, dynamic>> get _votes =>
      _firestore.collection('votes');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<List<ElectionModel>> streamElections() {
    return _elections
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ElectionModel.fromDoc)
              .toList()
            ..sort((a, b) {
              if (a.isActive == b.isActive) {
                return b.createdAt.compareTo(a.createdAt);
              }
              return a.isActive ? -1 : 1;
            }),
        );
  }

  Stream<List<CandidateModel>> streamCandidates(String electionId) {
    return _elections
        .doc(electionId)
        .collection('candidates')
        .orderBy('voteCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CandidateModel.fromDoc).toList());
  }

  Future<void> syncUserProfile({
    required String userId,
    required String name,
    required String email,
  }) {
    return _users.doc(userId).set(
      {
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<bool> hasUserVoted({
    required String userId,
    required String electionId,
  }) async {
    final votedDoc = await _users
        .doc(userId)
        .collection('votedElections')
        .doc(electionId)
        .get();
    return votedDoc.exists;
  }

  Future<void> castVote({
    required String userId,
    required String electionId,
    required String candidateId,
  }) async {
    final voteId = _voteDocumentId(electionId, userId);
    final voteRef = _votes.doc(voteId);
    final electionRef = _elections.doc(electionId);
    final candidateRef = electionRef.collection('candidates').doc(candidateId);
    final userRef = _users.doc(userId);
    final votedElectionRef = userRef.collection('votedElections').doc(electionId);

    await _firestore.runTransaction((transaction) async {
      final existingVote = await transaction.get(voteRef);
      final votedElection = await transaction.get(votedElectionRef);
      if (existingVote.exists || votedElection.exists) {
        throw Exception('You have already voted in this election.');
      }

      final electionSnapshot = await transaction.get(electionRef);
      final candidateSnapshot = await transaction.get(candidateRef);

      if (!electionSnapshot.exists) {
        throw Exception('Election not found.');
      }

      if (!candidateSnapshot.exists) {
        throw Exception('Candidate not found.');
      }

      final electionData = electionSnapshot.data() ?? <String, dynamic>{};
      if (electionData['status'] != 'active') {
        throw Exception('This election is closed.');
      }

      transaction.set(voteRef, {
        'userId': userId,
        'electionId': electionId,
        'candidateId': candidateId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.set(votedElectionRef, {
        'electionId': electionId,
        'candidateId': candidateId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.set(
        userRef,
        {
          'lastSeen': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.update(candidateRef, {
        'voteCount': FieldValue.increment(1),
      });

      transaction.update(electionRef, {
        'totalVotes': FieldValue.increment(1),
      });
    });
  }

  Future<void> createElection({
    required String title,
    required String description,
    required String type,
    required String joinCode,
    required List<CandidateModel> candidates,
  }) async {
    final electionRef = _elections.doc();
    final batch = _firestore.batch();

    batch.set(electionRef, {
      'title': title,
      'description': description,
      'type': type,
      'status': 'active',
      'joinCode': joinCode,
      'createdAt': FieldValue.serverTimestamp(),
      'candidateCount': candidates.length,
      'totalVotes': 0,
    });

    for (final candidate in candidates) {
      final candidateRef = electionRef.collection('candidates').doc();
      batch.set(candidateRef, candidate.toMap());
    }

    await batch.commit();
  }

  Future<void> updateElectionStatus({
    required String electionId,
    required String status,
  }) async {
    await _elections.doc(electionId).update({'status': status});
  }

  Future<void> seedSampleElections() async {
    await _createSampleElection(
      electionId: 'sample_college_election',
      title: 'Student Council Presidential Vote',
      description:
          'Elect the student leader for the upcoming academic year and choose '
          'the agenda that will represent campus priorities.',
      type: 'college',
      joinCode: 'DEMO2025',
      candidates: const [
        CandidateModel(
          id: 'c1',
          name: 'Aarav Mehta',
          position: 'President',
          party: 'Innovators Union',
          voteCount: 0,
        ),
        CandidateModel(
          id: 'c2',
          name: 'Riya Kapoor',
          position: 'President',
          party: 'Campus Forward',
          voteCount: 0,
        ),
        CandidateModel(
          id: 'c3',
          name: 'Kabir Nair',
          position: 'President',
          party: 'Student Voice',
          voteCount: 0,
        ),
      ],
    );

    await _createSampleElection(
      electionId: 'sample_local_election',
      title: 'Ward 7 Community Development Poll',
      description:
          'Vote for the candidate who will lead neighborhood infrastructure, '
          'sanitation, and civic improvement priorities.',
      type: 'local',
      joinCode: 'DEMO2025',
      candidates: const [
        CandidateModel(
          id: 'l1',
          name: 'Neha Sharma',
          position: 'Ward Representative',
          party: 'People First',
          voteCount: 0,
        ),
        CandidateModel(
          id: 'l2',
          name: 'Vikram Rao',
          position: 'Ward Representative',
          party: 'Progress Alliance',
          voteCount: 0,
        ),
      ],
    );
  }

  Future<void> _createSampleElection({
    required String electionId,
    required String title,
    required String description,
    required String type,
    required String joinCode,
    required List<CandidateModel> candidates,
  }) async {
    final electionRef = _elections.doc(electionId);
    final batch = _firestore.batch();

    batch.set(
      electionRef,
      {
        'title': title,
        'description': description,
        'type': type,
        'status': 'active',
        'joinCode': joinCode,
        'createdAt': FieldValue.serverTimestamp(),
        'candidateCount': candidates.length,
        'totalVotes': 0,
      },
      SetOptions(merge: true),
    );

    for (final candidate in candidates) {
      final candidateRef = electionRef.collection('candidates').doc(candidate.id);
      batch.set(candidateRef, candidate.toMap(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  String _voteDocumentId(String electionId, String userId) {
    return '${electionId}_$userId';
  }
}
