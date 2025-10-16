import 'package:flutter/material.dart';

void main() => runApp(const TraceItApp());

class TraceItApp extends StatelessWidget {
  const TraceItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraceIt',
      debugShowCheckedModeBanner: false,
      home: const SignInScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/lostItem': (_) => const LostItemScreen(),
        '/foundItem': (_) => const FoundItemScreen(),
        '/map': (_) => const MapScreen(),
        '/chat': (_) => const ChatScreen(),
        '/adminHome': (_) => const AdminHomeScreen(),
        '/adminDashboard': (_) => const AdminDashboardScreen(),
        '/adminSearch': (_) => const AdminSearchScreen(),
      },
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: SizedBox.shrink(),
    );
  }
}

class LostItemScreen extends StatelessWidget {
  const LostItemScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Report Lost Item')),
      body: SizedBox.shrink(),
    );
  }
}

class FoundItemScreen extends StatelessWidget {
  const FoundItemScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Report Found Item')),
      body: SizedBox.shrink(),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: SizedBox.shrink(),
    );
  }
}