import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'configure/providers/blindspot_provider.dart';
import 'configure/providers/fatigue_provider.dart';
import 'configure/screens/home_screen.dart';
import 'configure/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RiderGuardApp());
}

class RiderGuardApp extends StatelessWidget {
  const RiderGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BlindspotProvider()),
        ChangeNotifierProvider(create: (_) => FatigueProvider()),
      ],
      child: MaterialApp(
        title: 'RiderGuard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}