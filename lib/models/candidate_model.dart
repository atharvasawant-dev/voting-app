import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateModel {
  const CandidateModel({
    required this.id,
    required this.name,
    required this.position,
    required this.party,
    required this.voteCount,
  });

  final String id;
  final String name;
  final String position;
  final String party;
  final int voteCount;

  factory CandidateModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CandidateModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      position: data['position'] as String? ?? '',
      party: data['party'] as String? ?? '',
      voteCount: (data['voteCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'party': party,
      'voteCount': voteCount,
    };
  }
}
