import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/terms_provider.dart';
import 'home_screen.dart';

class TermsScreen extends StatefulWidget {
  final bool readOnly;

  const TermsScreen({super.key, this.readOnly = false});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final termsProvider = Provider.of<TermsProvider>(context);

    return PopScope(
      canPop: widget.readOnly || termsProvider.termsAccepted,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conditions d\'utilisation'),
          automaticallyImplyLeading: widget.readOnly,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conditions Générales d\'Utilisation',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Objet
                    _sectionTitle('1. Objet', colorScheme),
                    const SizedBox(height: 4),
                    _sectionBody(
                      'L\'application Sargassoti est un outil '
                      'de signalement participatif permettant aux utilisateurs de consulter et de '
                      'partager des informations sur les conditions des plages de Guadeloupe : '
                      'niveaux de sargasses, de vagues, d\'affluence et de bruit. '
                      'L\'application est fournie à titre indicatif et non commercial.',
                    ),
                    const SizedBox(height: 12),

                    // Données déclaratives
                    _sectionTitle('2. Données déclaratives', colorScheme),
                    const SizedBox(height: 4),
                    _sectionBody(
                      'Les informations publiées sur l\'application sont fournies par les '
                      'utilisateurs et n\'ont pas fait l\'objet d\'une vérification par l\'éditeur. '
                      'Elles reflètent la perception individuelle des rapporteurs au moment du '
                      'signalement et peuvent être inexactes, incomplètes ou obsolètes.',
                    ),
                    const SizedBox(height: 12),

                    // Absence de responsabilité
                    _sectionTitle('3. Absence de responsabilité', colorScheme),
                    const SizedBox(height: 4),
                    _sectionBody(
                      'L\'éditeur de l\'application ne saurait être tenu responsable des '
                      'décisions ou actions entreprises par les utilisateurs sur la base des '
                      'informations contenues dans l\'application. En particulier, l\'éditeur '
                      'ne garantit pas :\n\n'
                      '• que le niveau de vagues signalé reflète l\'état réel de la mer ;\n'
                      '• que l\'absence de sargasses signalée signifie l\'absence effective '
                      'de sargasses sur la plage ;\n'
                      '• que le niveau d\'affluence ou de bruit signalé correspond à la '
                      'situation présente.\n\n'
                      'L\'utilisation de l\'application ne remplace en aucun cas les '
                      'avertissements officiels, les informations des autorités locales '
                      'ou le jugement personnel de l\'utilisateur.',
                    ),
                    const SizedBox(height: 12),

                    // Obligation de bon sens
                    _sectionTitle('4. Obligation de prudence', colorScheme),
                    const SizedBox(height: 4),
                    _sectionBody(
                      'L\'utilisateur reconnaît que les conditions en bord de mer sont '
                      'par nature changeantes et potentiellement dangereuses. Il lui incombe '
                      'de faire preuve de bon sens, de prudence et de vérifier par lui-même '
                      'les conditions sur place avant de s\'engager dans toute activité. '
                      'L\'application est un simple indicateur de confort et non un outil '
                      'de sécurité.',
                    ),
                    const SizedBox(height: 12),

                    // Modification
                    _sectionTitle('5. Modification des conditions', colorScheme),
                    const SizedBox(height: 4),
                    _sectionBody(
                      'L\'éditeur se réserve le droit de modifier les présentes conditions '
                      'à tout moment. La poursuite de l\'utilisation de l\'application après '
                      'toute modification vaut acceptation des nouvelles conditions.',
                    ),
                    const SizedBox(height: 12),

                    // Contact
                    _sectionTitle('6. Contact', colorScheme),
                    const SizedBox(height: 4),
                    _sectionBody(
                      'Pour toute question relative aux présentes conditions, vous pouvez '
                      'contacter l\'éditeur à l\'adresse indiquée sur la page d\'accueil de '
                      'l\'application.',
                    ),
                  ],
                ),
              ),
            ),

            // Boutons d'action (uniquement si pas en mode lecture seule)
            if (!widget.readOnly) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await termsProvider.acceptTerms();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                            );
                          }
                        },
                        child: const Text(
                          'J\'accepte',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vous devez accepter les conditions pour utiliser l\'application.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        child: const Text(
                          'Je refuse',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _sectionBody(String body) {
    return Text(
      body,
      style: const TextStyle(fontSize: 14, height: 1.5),
      textAlign: TextAlign.justify,
    );
  }
}