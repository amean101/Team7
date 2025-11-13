import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/login.dart';

const kPrimary = Color(0xFF3B82F6);
const kSecondary = Color(0xFF10B981);
const kSurface = Color(0xFFF5F7FB);
const kBorder = Color(0xFFD5DBE7);
const kError = Color(0xFFEF4444);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TraceItApp());
}

class TraceItApp extends StatelessWidget {
  const TraceItApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: kPrimary,
      brightness: Brightness.light,
    ).copyWith(secondary: kSecondary, surface: kSurface, error: kError);

    return MaterialApp(
      title: 'TraceIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: baseScheme,
        fontFamily: 'Verdana',
        scaffoldBackgroundColor: kSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurface,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: kPrimary, width: 1.2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kSecondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: kBorder),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
      home: const _AuthGate(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/auth': (_) => const AuthenticationScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/lostItem': (_) => const LostItemScreen(),
        '/foundItem': (_) => const FoundItemScreen(),
        '/map': (_) => const MapScreen(),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (s.data != null) {
          return const HomeScreen();
        }
        return const AuthenticationScreen();
      },
    );
  }
}

class _FooterIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSelected;

  const _FooterIconButton({
    required this.icon,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: 28,
          color: Colors.black,
          onPressed: onPressed,
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: const Center(child: SizedBox.shrink()),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFDDDDDD),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FooterIconButton(
                  icon: Icons.explore_outlined,
                  onPressed: () => Navigator.pushNamed(context, '/map'),
                ),
                _FooterIconButton(
                  icon: Icons.home,
                  isSelected: true,
                  onPressed: () {},
                ),
                _FooterIconButton(
                  icon: Icons.chat_bubble_outline,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LostItemScreen extends StatelessWidget {
  const LostItemScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

class FoundItemScreen extends StatelessWidget {
  const FoundItemScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
