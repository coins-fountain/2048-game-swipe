import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_n_merge/provider/ads_service.dart';
import 'package:swipe_n_merge/provider/consent_service.dart';
import 'package:swipe_n_merge/provider/game_provider.dart';
import 'package:swipe_n_merge/screen/introduce_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConsentService(),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider()..loadSavedGame(),
        ),
        ChangeNotifierProxyProvider<ConsentService, AdService>(
          create: (context) => AdService(
            consentService: Provider.of<ConsentService>(context, listen: false),
          ),
          update: (context, consent, previous) {
            return previous ?? AdService(consentService: consent);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swipe N Merge 2048',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}