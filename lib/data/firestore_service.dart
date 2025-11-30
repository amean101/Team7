import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Single shared collection for all lost/found items
  CollectionReference get _itemsCollection => _firestore.collection('items');

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

      if (imageFile != null && imageFile.path != 'test_image_marker') {
        final fileName = '${userId}_${now.millisecondsSinceEpoch}.jpg';
        final storageRef = _storage.ref().child('items/$fileName');
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      final docRef = await _itemsCollection.add({
        'userId': userId,
        'title': title,
        'description': description,
        'contactName': contactName,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone ?? '',
        'category': category ?? '',
        'imageUrl': imageUrl,
        'status': 'lost',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'claimedBy': null,
      });

      return docRef.id;
    } catch (e) {
      // This is what your "Failed to upload" is catching
      throw Exception('Failed to create lost item: $e');
    }
  }

  // All lost items (for FoundItemScreen, admin, etc.)
  Stream<List<Map<String, dynamic>>> getLostItemsStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

          return items.where((item) {
            final status = (item['status'] ?? 'lost').toString().toLowerCase();
            return status == 'lost';
          }).toList();
        });
  }

  // Current user's lost items (for LostItemScreen)
  Stream<List<Map<String, dynamic>>> getUserLostItemsStream(String userId) {
    return _itemsCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta == null || tb == null) return 0;
        return (tb as Timestamp).compareTo(ta as Timestamp);
      });

      return items.where((item) {
        final status = (item['status'] ?? 'lost').toString().toLowerCase();
        return status == 'lost';
      }).toList();
    });
  }

  Future<void> updateItemStatus({
    required String itemId,
    required String status,
    String? claimedBy,
  }) async {
    try {
      await _itemsCollection.doc(itemId).update({
        'status': status,
        'claimedBy': claimedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  Future<void> deleteItem(String itemId, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Failed to delete image: $e');
        }
      }

      await _itemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchItems(String query) async {
    try {
      final snapshot = await _itemsCollection
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      final q = query.trim().toLowerCase();
      if (q.isEmpty) return items;

      return items.where((item) {
        final title = (item['title'] ?? '').toString().toLowerCase();
        final description = (item['description'] ?? '')
            .toString()
            .toLowerCase();
        return title.contains(q) || description.contains(q);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }
}
