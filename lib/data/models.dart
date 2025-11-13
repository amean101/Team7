class TItem {
  final String? id;
  final String title;
  final String description;
  final String? categoryId;
  final String status;
  final DateTime foundTime;
  final String? foundLocationId;
  final String reportedBy;
  final String? claimedBy;
  final String? storageRef;
  final String? primaryPhotoId;
  final DateTime createdAt;
  final DateTime updatedAt;
// constructor
  TItem({
    this.id,
    required this.title,
    required this.description,
    this.categoryId,
    required this.status,
    required this.foundTime,
    this.foundLocationId,
    required this.reportedBy,
    this.claimedBy,
    this.storageRef,
    this.primaryPhotoId,
    required this.createdAt,
    required this.updatedAt,
  });
// copy with
  TItem copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? status,
    DateTime? foundTime,
    String? foundLocationId,
    String? reportedBy,
    String? claimedBy,
    String? storageRef,
    String? primaryPhotoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      TItem(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        status: status ?? this.status,
        foundTime: foundTime ?? this.foundTime,
        foundLocationId: foundLocationId ?? this.foundLocationId,
        reportedBy: reportedBy ?? this.reportedBy,
        claimedBy: claimedBy ?? this.claimedBy,
        storageRef: storageRef ?? this.storageRef,
        primaryPhotoId: primaryPhotoId ?? this.primaryPhotoId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
// to map
  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category_id': categoryId,
        'status': status,
        'found_time': foundTime.toIso8601String(),
        'found_location_id': foundLocationId,
        'reported_by': reportedBy,
        'claimed_by': claimedBy,
        'storage_ref': storageRef,
        'primary_photo_id': primaryPhotoId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
// from map
  static TItem fromMap(Map<String, Object?> m) => TItem(
        id: m['id'] as String?,
        title: m['title'] as String,
        description: (m['description'] as String?) ?? '',
        categoryId: m['category_id'] as String?,
        status: m['status'] as String,
        foundTime: DateTime.parse(m['found_time'] as String),
        foundLocationId: m['found_location_id'] as String?,
        reportedBy: m['reported_by'] as String,
        claimedBy: m['claimed_by'] as String?,
        storageRef: m['storage_ref'] as String?,
        primaryPhotoId: m['primary_photo_id'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );
}
