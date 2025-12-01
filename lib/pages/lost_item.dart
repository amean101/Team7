import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/firestore_service.dart';

class LostItemScreen extends StatefulWidget {
  const LostItemScreen({super.key});

  @override
  State<LostItemScreen> createState() => _LostItemScreenState();
}

class _LostItemScreenState extends State<LostItemScreen> {
  final _imagePicker = ImagePicker();
  final _firestoreService = FirestoreService.instance;

  String _title = '';
  String _description = '';
  String _contactName = '';
  String _contactEmail = '';
  String _contactPhone = '';
  String _selectedCategory = '';
  File? _imageFile;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Accessories',
    'Keys',
    'Wallet',
    'Bag',
    'Other',
  ];

  List<Map<String, dynamic>> _lostItems = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8E8E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lost Item',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in first'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getUserLostItemsStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _lostItems = snapshot.data!;
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_lostItems.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'You have ${_lostItems.length} item${_lostItems.length == 1 ? '' : 's'} reported. Add more below!',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        _buildSectionTile(
                          label: 'Title',
                          value: _title.isEmpty
                              ? 'Short name for your item (e.g. "Black iPhone 13")'
                              : _title,
                          onTap: _showTitleDialog,
                          hasValue: _title.isNotEmpty,
                        ),

                        const SizedBox(height: 12),

                        _buildSectionTile(
                          label: 'Category',
                          value: _selectedCategory.isEmpty
                              ? 'Select a category'
                              : _selectedCategory,
                          onTap: _showCategoryDialog,
                          hasValue: _selectedCategory.isNotEmpty,
                        ),

                        const SizedBox(height: 12),

                        _buildSectionTile(
                          label: 'Description',
                          value: _description.isEmpty
                              ? 'Add a description of your item'
                              : _description,
                          onTap: _showDescriptionDialog,
                          hasValue: _description.isNotEmpty,
                        ),

                        const SizedBox(height: 12),

                        _buildSectionTile(
                          label: 'Contact',
                          value: _contactName.isEmpty
                              ? 'Name\nEmail | Phone'
                              : '$_contactName\n$_contactEmail${_contactPhone.isNotEmpty ? " | $_contactPhone" : ""}',
                          onTap: _showContactDialog,
                          hasValue: _contactName.isNotEmpty,
                        ),

                        const SizedBox(height: 12),

                        _buildSectionTile(
                          label: 'Image (optional)',
                          value: _imageFile == null
                              ? 'Upload an image of the item'
                              : _imageFile!.path == 'test_image_marker'
                              ? 'Test image selected ✓'
                              : 'Image selected ✓',
                          onTap: _showImageOptions,
                          hasValue: _imageFile != null,
                          trailing: _imageFile != null
                              ? _imageFile!.path == 'test_image_marker'
                                    ? Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.blue,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _imageFile!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                              : null,
                        ),

                        const SizedBox(height: 24),

                        const Divider(thickness: 2, height: 32),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Lost Items',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_lostItems.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'ITEMS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'DESCRIPTION',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'STATUS',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            _lostItems.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_lostItems.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No lost items yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Fill the form above to report your first lost item.\nYou can add as many items as you need!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...(_lostItems.map(
                            (item) => _buildLostItemCard(item),
                          )),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _uploadLostItem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_circle_outline,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _lostItems.isEmpty
                                            ? 'Upload Lost Item'
                                            : 'Add Another Lost Item',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFDDDDDD),
              blurRadius: 8,
              offset: Offset(0, -2),
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
                  icon: Icons.navigation_outlined,
                  onPressed: () => Navigator.pushNamed(context, '/map'),
                ),
                _FooterIconButton(
                  icon: Icons.home,
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                ),
                _FooterIconButton(
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => Navigator.pushNamed(context, '/chat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadLostItem() async {
    if (_title.trim().isEmpty) {
      _showError('Please add a title');
      return;
    }
    if (_description.trim().isEmpty) {
      _showError('Please add a description');
      return;
    }
    if (_contactName.trim().isEmpty || _contactEmail.trim().isEmpty) {
      _showError('Please add your contact information');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError('Please log in first');
        setState(() => _isUploading = false);
        return;
      }

      await _firestoreService.createLostItem(
        userId: currentUser.uid,
        title: _title.trim(),
        description: _description,
        contactName: _contactName,
        contactEmail: _contactEmail,
        contactPhone: _contactPhone,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
        imageFile: _imageFile,
      );

      if (mounted) {
        setState(() {
          _title = '';
          _description = '';
          _contactName = '';
          _contactEmail = '';
          _contactPhone = '';
          _selectedCategory = '';
          _imageFile = null;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lost item uploaded successfully! Total: ${_lostItems.length + 1} items',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to upload: $e');
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateItemStatus(Map<String, dynamic> item) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Lost'),
              leading: const Icon(Icons.search, color: Colors.red),
              onTap: () => Navigator.pop(context, 'lost'),
            ),
            ListTile(
              title: const Text('Found'),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () => Navigator.pop(context, 'found'),
            ),
            ListTile(
              title: const Text('Returned'),
              leading: const Icon(Icons.inbox, color: Colors.blue),
              onTap: () => Navigator.pop(context, 'returned'),
            ),
          ],
        ),
      ),
    );

    if (newStatus != null) {
      try {
        await _firestoreService.updateItemStatus(
          itemId: item['id'],
          status: newStatus,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to ${newStatus.toUpperCase()}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        _showError('Failed to update status: $e');
      }
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteItem(item['id'], item['imageUrl']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        _showError('Failed to delete: $e');
      }
    }
  }

  Widget _buildSectionTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool hasValue = false,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: hasValue ? Border.all(color: Colors.green, width: 2) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (hasValue) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasValue ? Colors.black87 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLostItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                ? Image.network(
                    item['imageUrl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade500,
                          size: 30,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey.shade500,
                      size: 30,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item['description'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _updateItemStatus(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['status'] ?? 'lost'),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (item['status'] ?? 'lost').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _deleteItem(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lost':
        return Colors.red;
      case 'found':
        return Colors.green;
      case 'claimed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showTitleDialog() {
    final controller = TextEditingController(text: _title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item Title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Short name for your item',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _title = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog() {
    String temp = _selectedCategory.isEmpty
        ? (_categories.isNotEmpty ? _categories.first : '')
        : _selectedCategory;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Category'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return DropdownButton<String>(
              value: temp.isEmpty ? null : temp,
              isExpanded: true,
              hint: const Text('Select a category'),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setStateDialog(() => temp = value);
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _selectedCategory = temp);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDescriptionDialog() {
    final controller = TextEditingController(text: _description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item Description'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText:
                'Describe the lost item in detail...\ne.g. "Black iPhone 13 with blue case"',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _description = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    final nameController = TextEditingController(text: _contactName);
    final emailController = TextEditingController(text: _contactEmail);
    final phoneController = TextEditingController(text: _contactPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contactName = nameController.text;
                _contactEmail = emailController.text;
                _contactPhone = phoneController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('Use Test Image'),
              onTap: () {
                Navigator.pop(context);
                _useTestImage();
              },
            ),
            if (_imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imageFile = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _imageFile = File(image.path));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() => _imageFile = File(photo.path));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  void _useTestImage() {
    setState(() => _imageFile = File('test_image_marker'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test image mode enabled'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
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
