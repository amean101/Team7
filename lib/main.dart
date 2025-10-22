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
        //'/chat': (_) => const ChatScreen(),
        //'/adminHome': (_) => const AdminHomeScreen(),
        //'/adminDashboard': (_) => const AdminDashboardScreen(),
        //'/adminSearch': (_) => const AdminSearchScreen(),
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

//** Sign In Screen **

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/home'),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}

//** Home Screen **

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(child: Column()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
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
                  onPressed: () {
                    // ** Add navigation functionality to Map Screen **
                  },
                ),
                _FooterIconButton(
                  icon: Icons.home,
                  isSelected: true,
                  onPressed: () {
                    // ** Home Screen is already selected **
                  },
                ),
                _FooterIconButton(
                  icon: Icons.chat_bubble_outline,
                  onPressed: () {
                    // Add navigation functionality to Chat Screen **
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//** Lost Item Screen **

class LostItemScreen extends StatelessWidget {
  const LostItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

//** Found Item Screen **

class FoundItemScreen extends StatelessWidget {
  const FoundItemScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

//** Map Screen **

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
