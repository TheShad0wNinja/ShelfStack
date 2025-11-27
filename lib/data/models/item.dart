class Item {
  final String id;
  final String name;
  final String? description;
  final String? photoUrl;
  final List<String> tags;
  final String containerId;
  final String? externalDocumentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Item({
    required this.id,
    required this.name,
    this.description,
    this.photoUrl,
    required this.tags,
    required this.containerId,
    this.externalDocumentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? photoUrl,
    List<String>? tags,
    String? containerId,
    String? externalDocumentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      tags: tags ?? this.tags,
      containerId: containerId ?? this.containerId,
      externalDocumentUrl: externalDocumentUrl ?? this.externalDocumentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo_url': photoUrl,
      'container_id': containerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json, List<String> tags) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?,
      tags: tags,
      containerId: json['container_id'] as String,
      externalDocumentUrl: null, // Will be loaded separately if needed
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
