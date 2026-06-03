// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/beach_card.dart';
import '../services/firestore_service.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import 'terms_screen.dart';
import '../models/beach_report.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firestore = FirestoreService();

  // === FILTRES ===
  bool filterNoSargasses = false;
  bool filterLowWaves = false;
  bool filterLowCrowd = false;
  bool filterLowNoise = false;

  // === BOUTON FILTRE ===
  Widget _buildFilterButton(
      String label, bool isActive, VoidCallback onTap, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color:
                    isActive ? colorScheme.onPrimary : colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kantan Gwadloup!')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Kantan Gwadloup!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Conditions d\'utilisation'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TermsScreen(readOnly: true)),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // === BARRE DE FILTRES ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('Sans sargasses', filterNoSargasses, () {
                    setState(() => filterNoSargasses = !filterNoSargasses);
                  }, Icons.eco),
                  _buildFilterButton('Peu de vagues', filterLowWaves, () {
                    setState(() => filterLowWaves = !filterLowWaves);
                  }, Icons.waves),
                  _buildFilterButton('Peu de monde', filterLowCrowd, () {
                    setState(() => filterLowCrowd = !filterLowCrowd);
                  }, Icons.people_outline),
                  _buildFilterButton('Calme', filterLowNoise, () {
                    setState(() => filterLowNoise = !filterLowNoise);
                  }, Icons.volume_off),
                ],
              ),
            ),
          ),

          // === LISTE DES PLAGES ===
          Expanded(
            child: StreamBuilder<Map<String, int>>(
              stream: firestore.getBeachPopularity(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final popularity = snapshot.data ?? {};
                final sortedBeaches = popularity.keys.toList()
                  ..sort((a, b) =>
                      (popularity[b] ?? 0).compareTo(popularity[a] ?? 0));

                if (sortedBeaches.isEmpty) {
                  return const Center(child: Text('Aucune plage enregistrée.'));
                }

                return ListView.builder(
                  itemCount: sortedBeaches.length,
                  itemBuilder: (context, index) {
                    final beachName = sortedBeaches[index];
                    final beachId =
                        beachName.trim().toLowerCase().replaceAll(' ', '-');

                    // === NOUVEAU : RÉCUPÉRER LE DERNIER REPORT (pour imagePath) ===
                    return StreamBuilder<List<BeachReport>>(
                      stream: firestore.getReports(beachId),
                      builder: (context, reportSnapshot) {
                        String? imagePath;
                        if (reportSnapshot.hasData &&
                            reportSnapshot.data!.isNotEmpty) {
                          final latestReport = reportSnapshot.data!.first;
                          imagePath = latestReport.imagePath;
                        } else {
                          imagePath = "$beachId-min.jpg";
                        }
                        return BeachCard(
                          imagePath: imagePath,
                          beachName: beachName,
                          beachId: beachId,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ReportScreen(beachName: beachName)),
                          ),
                          filterNoSargasses: filterNoSargasses,
                          filterLowWaves: filterLowWaves,
                          filterLowCrowd: filterLowCrowd,
                          filterLowNoise: filterLowNoise,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          //'=== Signature ==='
          // const Spacer(), // ← Pousse en bas
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Dev: \u{1f60e}github.com/loicdurand - Crédits photos: T.Sato©",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
