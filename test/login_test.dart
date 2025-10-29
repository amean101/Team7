import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class SimpleLogin extends StatelessWidget {
  const SimpleLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TextField(key: Key('email')),
          const TextField(key: Key('password')),
          ElevatedButton(
            key: const Key('login'),
            onPressed: () {},
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

void main() { 

  // Checks if Login Widget Exists
  testWidgets('Login widgets exist', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SimpleLogin()));

    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  // Test button tap
  testWidgets('Can tap login button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SimpleLogin()));

    await tester.tap(find.byKey(const Key('login')));
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);
  });
}
