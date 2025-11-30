import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference get _lostItemsCollection =>
      _firestore.collection('lost_items');

  // Create a lost item
  Future<String> createLostItem({
    required String userId,
    required String title,
    required String description,
    required String contactName,
    required String contactEmail,
    String? contactPhone,
    String? category,
    File? imageFile,
  }) async {
    try {
      final now = DateTime.now();
      String? imageUrl;

      // Upload image to Firebase Storage if provided
      if (imageFile != null && imageFile.path != 'test_image_marker') {
        final fileName = '${userId}_${now.millisecondsSinceEpoch}.jpg';
        final storageRef = _storage.ref().child('lost_items/$fileName');
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Create document
      final docRef = await _lostItemsCollection.add({
        'userId': userId,
        'title': title,
        'description': description,
        'contactName': contactName,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone ?? '',
        'category': category,
        'imageUrl': imageUrl,
        'status': 'lost',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'claimedBy': null,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create lost item: $e');
    }
  }

  // Get all lost items (for search page)
  Stream<List<Map<String, dynamic>>> getLostItemsStream() {
    return _lostItemsCollection
        .where('status', isEqualTo: 'lost')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Get user's lost items
  Stream<List<Map<String, dynamic>>> getUserLostItemsStream(String userId) {
    return _lostItemsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'lost')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Update item status
  Future<void> updateItemStatus({
    required String itemId,
    required String status,
    String? claimedBy,
  }) async {
    try {
      await _lostItemsCollection.doc(itemId).update({
        'status': status,
        'claimedBy': claimedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId, String? imageUrl) async {
    try {
      // Delete image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Failed to delete image: $e');
        }
      }

      // Delete document
      await _lostItemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Search items
  Future<List<Map<String, dynamic>>> searchItems(String query) async {
    try {
      final snapshot = await _lostItemsCollection
          .where('status', isEqualTo: 'lost')
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter by search query
      if (query.isEmpty) return items;

      return items.where((item) {
        final title = (item['title'] as String).toLowerCase();
        final description = (item['description'] as String).toLowerCase();
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }
}
