import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await NotificationService.instance.initialize();
  runApp(const NutriBells());
}

class NutriBells extends StatefulWidget {
  const NutriBells({super.key});

  @override
  State<NutriBells> createState() => _NutriBellsState();
}

class _NutriBellsState extends State<NutriBells> {
  late final Future<void> _restoreSession;

  @override
  void initState() {
    super.initState();
    _restoreSession = AuthService().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _restoreSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          title: 'NutriBells',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF800020),
              primary: const Color(0xFF800020),
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
          ),
          builder: (context, child) => Container(
            color: const Color(0xFFF2E9EC),
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: child,
            ),
          ),
          home: AuthService.currentUser == null
              ? const LoginScreen()
              : const HomeScreen(),
        );
      },
    );
  }
}
