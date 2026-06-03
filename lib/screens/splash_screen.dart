import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/terms_provider.dart';
import 'home_screen.dart';
import 'terms_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final termsProvider = Provider.of<TermsProvider>(context, listen: false);

    if (termsProvider.termsAccepted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TermsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          image: DecorationImage(
            image: const AssetImage('assets/beach.jpg'),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) =>
                debugPrint("Image failed"),
          ),
        ),
        child: const Center(
          child: Text(
            'Kantan Gwadloup!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                    blurRadius: 4, color: Colors.black54, offset: Offset(2, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}