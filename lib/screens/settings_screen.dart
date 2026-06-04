import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _onVersionTap(AdminAuthProvider authProvider) {
    final now = DateTime.now();

    // Reset le compteur si plus de 3 secondes se sont écoulées
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inSeconds >= 3) {
      _tapCount = 0;
    }

    _lastTapTime = now;
    _tapCount++;

    // Annule le timer de reset précédent
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 3), () {
      _tapCount = 0;
    });

    if (_tapCount >= 7) {
      _tapCount = 0;
      _resetTimer?.cancel();

      if (authProvider.isAdminMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mode administrateur déjà débloqué'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        authProvider.unlockAdminMode();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔓 Mode administrateur débloqué'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AdminAuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === SÉLECTEUR DE THÈME ===
            const Text(
              'Thème de l\'application',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: themeProvider.themeMode == ThemeMode.light
                  ? 'light'
                  : themeProvider.themeMode == ThemeMode.dark
                      ? 'dark'
                      : 'system',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              items: const [
                DropdownMenuItem(
                    value: 'system', child: Text('Suivre le système')),
                DropdownMenuItem(value: 'light', child: Text('Clair')),
                DropdownMenuItem(value: 'dark', child: Text('Sombre')),
              ],
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),

            // === SECTION ADMIN (conditionnelle) ===
            if (authProvider.isAdminMode) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Espace administrateur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              if (authProvider.isSigningIn)
                const Center(child: CircularProgressIndicator())
              else if (authProvider.user == null) ...[
                // Non connecté : bouton Google Sign-In
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => authProvider.signInWithGoogle(),
                    icon: Image.asset(
                      'assets/google_logo.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.login, size: 20),
                    ),
                    label: const Text('Se connecter avec Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                // Connecté : afficher email + statut admin
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        authProvider.user?.photoURL != null
                            ? NetworkImage(authProvider.user!.photoURL!)
                            : null,
                    child: authProvider.user?.photoURL == null
                        ? Text(authProvider.user?.displayName?.isNotEmpty == true
                            ? authProvider.user!.displayName![0].toUpperCase()
                            : '?')
                        : null,
                  ),
                  title: Text(
                    authProvider.user?.displayName ?? 'Utilisateur',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(authProvider.user?.email ?? ''),
                ),
                const SizedBox(height: 8),
                if (authProvider.isAdmin)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified,
                            color: Colors.green.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Administrateur',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber,
                            color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Compte non autorisé — contactez l\'administrateur',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => authProvider.signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                ),
              ],

              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  authProvider.errorMessage!,
                  style: TextStyle(color: colorScheme.error, fontSize: 13),
                ),
              ],
            ],

            // === ESPACEUR + VERSION ===
            const Spacer(),
            Center(
              child: GestureDetector(
                onTap: () => _onVersionTap(authProvider),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}