import 'package:flutter/material.dart';
import '../data/firestore_service.dart';

const _bg = Color.fromARGB(246, 220, 220, 221);

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _firestoreService = FirestoreService.instance;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String itemId, String newStatus) async {
    try {
      await _firestoreService.updateItemStatus(
        itemId: itemId,
        status: newStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lost & Found Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search by item, description, owner, or category',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                // SAME stream as FoundItemScreen
                stream: _firestoreService.getLostItemsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    // Show the real error to debug rules / path issues
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Error loading items:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                      ),
                    );
                  }

                  final allItems = snapshot.data ?? [];
                  final q = _searchCtrl.text.trim().toLowerCase();

                  final filtered = q.isEmpty
                      ? allItems
                      : allItems.where((data) {
                          final title = (data['title'] ?? '')
                              .toString()
                              .toLowerCase();
                          final desc = (data['description'] ?? '')
                              .toString()
                              .toLowerCase();
                          final owner = (data['contactName'] ?? '')
                              .toString()
                              .toLowerCase();
                          final category = (data['category'] ?? '')
                              .toString()
                              .toLowerCase();
                          return title.contains(q) ||
                              desc.contains(q) ||
                              owner.contains(q) ||
                              category.contains(q);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items found.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = filtered[index];

                      // FirestoreService should be adding this when it builds the map
                      final id = (data['id'] ?? '').toString();
                      final title = (data['title'] ?? 'Unnamed item')
                          .toString();
                      final desc = (data['description'] ?? '').toString();
                      final status = (data['status'] ?? 'lost')
                          .toString()
                          .toLowerCase();
                      final owner = (data['contactName'] ?? '').toString();
                      final category = (data['category'] ?? '').toString();
                      final imageUrl = (data['imageUrl'] ?? '').toString();

                      return _ItemCard(
                        title: title,
                        description: desc,
                        status: status,
                        owner: owner,
                        tags: category,
                        imageUrl: imageUrl.isEmpty ? null : imageUrl,
                        onReturn: id.isEmpty
                            ? null
                            : () => _updateStatus(id, 'returned'),
                        onArchive: id.isEmpty
                            ? null
                            : () => _updateStatus(id, 'archived'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final String owner;
  final String tags;
  final String? imageUrl;
  final VoidCallback? onReturn;
  final VoidCallback? onArchive;

  const _ItemCard({
    required this.title,
    required this.description,
    required this.status,
    required this.owner,
    required this.tags,
    this.imageUrl,
    this.onReturn,
    this.onArchive,
  });

  Color _statusColor() {
    final s = status.toLowerCase();
    if (s == 'returned') return const Color(0xFF22C55E);
    if (s == 'archived') return Colors.grey.shade600;
    if (s == 'found') return const Color(0xFF2563EB);
    if (s == 'claimed') return const Color(0xFF16A34A);
    if (s == 'lost') return const Color(0xFFDC2626);
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final canReturn = onReturn != null;
    final canArchive = onArchive != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemImage(imageUrl: imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (owner.isNotEmpty)
                  Text(
                    owner,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                if (owner.isNotEmpty) const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                if (description.isNotEmpty) const SizedBox(height: 2),
                if (tags.isNotEmpty)
                  Text(
                    tags,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor().withAlpha(20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(),
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: canReturn ? onReturn : null,
                      child: const Text(
                        'Return',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: canArchive ? onArchive : null,
                      child: const Text(
                        'Archive',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String? imageUrl;

  const _ItemImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    if (imageUrl == null) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade500,
          size: 28,
        ),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: borderRadius,
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade500,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
