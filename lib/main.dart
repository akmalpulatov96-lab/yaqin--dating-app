import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaqin/localization/app_localization.dart';
import 'package:yaqin/screens/auth_screen.dart';
import 'package:yaqin/screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization is guarded for offline/demo run
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init note: $e");
  }

  runApp(const YaqinApp());
}

class YaqinApp extends StatefulWidget {
  const YaqinApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _YaqinAppState? state = context.findAncestorStateOfType<_YaqinAppState>();
    state?.setLocale(newLocale);
  }

  static void toggleTheme(BuildContext context) {
    _YaqinAppState? state = context.findAncestorStateOfType<_YaqinAppState>();
    state?.toggleTheme();
  }

  @override
  State<YaqinApp> createState() => _YaqinAppState();
}

class _YaqinAppState extends State<YaqinApp> {
  Locale _locale = const Locale('ru');
  ThemeMode _themeMode = ThemeMode.dark;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yaqin',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        primaryColor: const Color(0xFFFF4B72),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF4B72),
          secondary: Color(0xFF7B2CBF),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        primaryColor: const Color(0xFFFF4B72),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4B72),
          secondary: Color(0xFF9D4EDD),
          surface: Color(0xFF1B1E2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B1E2E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('ru', ''),
        Locale('tg', ''),
      ],
      localizationsDelegates: const [
        YaqinLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4B72))),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return MainNavigation(currentUserId: snapshot.data!.uid);
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
