import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class _TestNavApp extends StatefulWidget {
  const _TestNavApp();

  @override
  State<_TestNavApp> createState() => _TestNavAppState();
}

class _TestNavAppState extends State<_TestNavApp> {
  int _index = 0;

  Widget _page() {
    if (_index == 0) return const Center(child: Text('Home Page', key: Key('homePage')));
    if (_index == 1) return const Center(child: Text('Nav Page', key: Key('navPage')));
    return const Center(child: Text('Chat Page', key: Key('chatPage')));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _page(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Nav'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Bottom nav switches between Home, Nav, and Chat', (tester) async {
    await tester.pumpWidget(const _TestNavApp());

    // initial = Home
    expect(find.text('Home Page'), findsOneWidget);
    expect(find.text('Nav Page'), findsNothing);
    expect(find.text('Chat Page'), findsNothing);

    // tap Nav
    await tester.tap(find.byIcon(Icons.navigation));
    await tester.pumpAndSettle();
    expect(find.text('Nav Page'), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);
    expect(find.text('Chat Page'), findsNothing);

    // tap Chat
    await tester.tap(find.byIcon(Icons.chat));
    await tester.pumpAndSettle();
    expect(find.text('Chat Page'), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);
    expect(find.text('Nav Page'), findsNothing);

    // tap Home
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.text('Home Page'), findsOneWidget);
    expect(find.text('Nav Page'), findsNothing);
    expect(find.text('Chat Page'), findsNothing);
  });
}
