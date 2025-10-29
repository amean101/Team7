// --- search_bar_test.dart ---
import 'package:flutter_test/flutter_test.dart';

// ✅ Define the function inside this file
List<String> searchItems(String keyword, List<String> items) {
  final lowerKeyword = keyword.toLowerCase();
  return items.where((item) => item.toLowerCase().contains(lowerKeyword)).toList();
}

void main() {
  group('Test Case 6 – Search Bar Functionality', () {
    late List<String> items;

    setUp(() {
      // Pre-condition: Items exist in the system
      items = ['Wallet', 'Phone Case', 'Wireless Mouse', 'Smart Watch', 'wallet chain'];
    });

    test('Ensure search returns correct and filtered results', () {
      // Test data
      const keyword = 'Wallet';

      // Step 1 & 2: Enter keyword and press search
      final results = searchItems(keyword, items);

      // Expected Result: Only matching items shown
      expect(results, ['Wallet', 'wallet chain']);
    });

    test('Include case-insensitive search test', () {
      const keyword = 'wallet';
      final results = searchItems(keyword, items);

      expect(results, ['Wallet', 'wallet chain']);
    });
  });
}
