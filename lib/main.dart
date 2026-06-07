import 'dart:async';

import 'package:r99/export.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLoadEnv.load();
  await SupabaseAuthService.initialize();
  await AppDatabase.instance.open();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R99 Printer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.themeSeed),
        scaffoldBackgroundColor: AppColor.appScaffoldBackground,
        useMaterial3: true,
      ),
      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool isLoggedIn = false;
  StreamSubscription<bool>? authSub;

  @override
  void initState() {
    super.initState();
    isLoggedIn = SupabaseAuthService.isSignedIn;

    if (SupabaseAuthService.isInitialized) {
      authSub = SupabaseAuthService.authStateChanges.listen((signedIn) {
        if (!mounted) return;
        if (isLoggedIn == signedIn) return;
        setState(() {
          isLoggedIn = signedIn;
        });
      });
    }
  }

  void login() {
    if (!mounted || isLoggedIn) return;
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return const PrinterPage();
    }

    return LoginPage(onLoginSuccess: login);
  }

  @override
  void dispose() {
    authSub?.cancel();
    super.dispose();
  }
}
