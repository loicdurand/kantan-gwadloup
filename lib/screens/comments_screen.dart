import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/beach_report.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';

class CommentsScreen extends StatelessWidget {
  final String beachId;
  final String beachName;

  const CommentsScreen({
    super.key,
    required this.beachId,
    required this.beachName,
  });

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    return "il y a ${diff.inDays} j";
  }

  void _confirmDeletePhoto(BuildContext context, BeachReport report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette photo ?'),
        content: const Text('La photo sera retirée de ce signalement. Le reste du signalement sera conservé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (report.documentId != null) {
                await FirestoreService().deleteReportPhoto(report.documentId!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo supprimée')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteComment(BuildContext context, BeachReport report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce commentaire ?'),
        content: Text('« ${report.comment} »\n\nCette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (report.documentId != null) {
                await FirestoreService().deleteReport(report.documentId!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Commentaire supprimé')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final authProvider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Commentaires - $beachName')),
      body: StreamBuilder<List<BeachReport>>(
        stream: firestore.getReports(beachId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun commentaire pour cette plage.'));
          }

          final reports = snapshot.data!
              .where((report) => report.comment != null)
              .toList();

          if (reports.isEmpty) {
            return const Center(child: Text('Aucun commentaire pour cette plage.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final tile = ListTile(
                contentPadding: EdgeInsets.zero,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.photoBase64 != null) ...[
                      GestureDetector(
                        onLongPress: authProvider.isAdmin && report.documentId != null
                            ? () => _confirmDeletePhoto(context, report)
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(report.photoBase64!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      '"${report.comment}"',
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                subtitle: Text(
                  _timeAgo(report.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              );

              // Long-press sur le commentaire pour supprimer (admin uniquement)
              if (authProvider.isAdmin && report.documentId != null) {
                return GestureDetector(
                  onLongPress: () => _confirmDeleteComment(context, report),
                  child: tile,
                );
              }
              return tile;
            },
          );
        },
      ),
    );
  }
}