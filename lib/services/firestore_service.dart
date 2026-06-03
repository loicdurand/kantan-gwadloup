import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/beach_report.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> reports =
      FirebaseFirestore.instance.collection('reports');

  Future<void> addReport(BeachReport report) async {
    await reports.add(report.toJson());
  }

  Stream<List<BeachReport>> getReports(String beachId) {
    return reports
        .where('beachId', isEqualTo: beachId)
        .orderBy('timestamp', descending: true)
        // .limit(3)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BeachReport.fromJson(doc.data()))
            .toList());
  }

  Future<List<BeachReport>> getReportsSync(String beachId) async {
    final snapshot = await reports
        .where('beachId', isEqualTo: beachId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    return snapshot.docs
        .map((doc) => BeachReport.fromJson(doc.data()))
        .toList();
  }

  Future<bool> canAddReport(String userId) async {
    final lastReportSnapshot = await reports
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastReportSnapshot.docs.isEmpty) return true; // Premier report OK

    final lastTimestamp = DateTime.parse(lastReportSnapshot.docs.first['timestamp']);
    final diff = DateTime.now().difference(lastTimestamp);

    return diff.inHours >= 0; // 2h min
  }

  Stream<List<String>> getBeachNames() {
    return reports.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc['beachName'] as String)
        .toSet()
        .toList());
  }

  Stream<Map<String, int>> getBeachPopularity() {
    return reports.snapshots().map((snapshot) {
      final Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        final name = doc['beachName'] as String;
        counts[name] = (counts[name] ?? 0) + 1;
      }
      return counts;
    });
  }
}
