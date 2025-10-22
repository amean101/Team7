import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _validEmail = 'afton@email.com';
const _validPass  = 'afton123';

class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();

  void _signIn() {
    final ok = _email.text.trim() == _validEmail && _pass.text == _validPass;
    if (ok) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('emailField'),
              controller: _email,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('passwordField'),
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('signInButton'),
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Screen', key: Key('homeScreenText'))),
    );
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: _LoginScreen());
  }
}

void main() {
  testWidgets('User Login navigates to Home Screen', (tester) async {
    await tester.pumpWidget(const _TestApp());

    await tester.enterText(find.byKey(const Key('emailField')), _validEmail);
    await tester.enterText(find.byKey(const Key('passwordField')), _validPass);
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('homeScreenText')), findsOneWidget);
  });
}
