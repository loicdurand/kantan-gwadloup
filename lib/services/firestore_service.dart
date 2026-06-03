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

  /// Vérifie si un utilisateur peut soumettre un signalement.
  ///
  /// - Même plage : délai minimum de 2 heures entre deux signalements
  /// - Plage différente : délai minimum de 15 minutes
  /// Cela empêche les votes massifs tout en permettant à un utilisateur
  /// honnête de signaler une autre plage rapidement.
  Future<bool> canAddReport(String userId, String beachId) async {
    final now = DateTime.now();

    // Dernier signalement de cet utilisateur sur cette même plage
    final lastSameBeachSnapshot = await reports
        .where('userId', isEqualTo: userId)
        .where('beachId', isEqualTo: beachId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastSameBeachSnapshot.docs.isNotEmpty) {
      final lastTimestamp = DateTime.parse(
          lastSameBeachSnapshot.docs.first['timestamp']);
      if (now.difference(lastTimestamp).inMinutes < 120) {
        return false; // Moins de 2h sur la même plage
      }
    }

    // Dernier signalement de cet utilisateur, quelle que soit la plage
    final lastAnyBeachSnapshot = await reports
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastAnyBeachSnapshot.docs.isNotEmpty) {
      final lastTimestamp = DateTime.parse(
          lastAnyBeachSnapshot.docs.first['timestamp']);
      if (now.difference(lastTimestamp).inMinutes < 15) {
        return false; // Moins de 15 min sur n'importe quelle plage
      }
    }

    return true;
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
