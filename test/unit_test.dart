import 'package:flutter_test/flutter_test.dart';
<<<<<<< HEAD
import 'package:traceit/main.dart';
=======
>>>>>>> origin/afton
import 'package:flutter/material.dart';

class MyTestWidget extends StatelessWidget {
  const MyTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Icon Test')),
      body: Center(
        child: IconButton(
          icon: const Icon(
            Icons.add,
          ), // Testing to see if the icon button works
          onPressed: () {},
        ),
      ),
    );
  }
}

void main() {
  testWidgets('NavigationButtons Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyTestWidget()));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
  });
<<<<<<< HEAD
}
=======
}
>>>>>>> origin/afton
