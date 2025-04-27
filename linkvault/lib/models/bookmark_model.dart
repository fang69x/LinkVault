class Bookmark {
  final String? id;
  final String title;
  final String url;
  final String? note;
  final String category;
  final List<String> tags;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Bookmark({
    this.id,
    required this.title,
    required this.url,
    this.note,
    required this.category,
    required this.tags,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['_id']?.toString(),
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      note: json['note'],
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      userId: _parseUserId(json['user']), // Use helper function
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

// Add this helper method
  static String _parseUserId(dynamic userData) {
    if (userData is String) return userData;
    if (userData is Map) return userData['_id']?.toString() ?? '';
    return '';
  }

// Update toJson to match server field name
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'note': note,
      'category': category,
      'tags': tags,
      'user': userId, // Map to 'user' field expected by server
    };
  }
}
