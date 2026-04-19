import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionModel {
  const ElectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.joinCode,
    required this.createdAt,
    required this.candidateCount,
    required this.totalVotes,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final String joinCode;
  final DateTime createdAt;
  final int candidateCount;
  final int totalVotes;

  bool get isActive => status == 'active';
  bool get isCollege => type == 'college';
  String get statusLabel => isActive ? 'Active' : 'Closed';
  String get typeLabel => isCollege ? 'College' : 'Local';

  factory ElectionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final created = data['createdAt'];

    return ElectionModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: data['type'] as String? ?? 'college',
      status: data['status'] as String? ?? 'active',
      joinCode: data['joinCode'] as String? ?? '',
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      candidateCount: (data['candidateCount'] as num?)?.toInt() ?? 0,
      totalVotes: (data['totalVotes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'joinCode': joinCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'candidateCount': candidateCount,
      'totalVotes': totalVotes,
    };
  }
}
