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
      id: json['_id'],
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      note: json['note'],
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      userId:
          json['user']?.toString() ?? '', // Convert ObjectId to string safely
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'note': note,
      'category': category,
      'tags': tags,
    };
  }
}
