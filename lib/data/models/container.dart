import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';

class Container {
  final String id;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Item> items;
  final List<String> tags;
  final Location location;

  const Container({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.location,
    required this.tags,
  });

  int get itemCount => items.length;

  Container copyWith({
    String? id,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Item>? items,
    List<String>? tags,
    Location? location,
  }) {
    return Container(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      location: location ?? this.location,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'Container{id: $id, name: $name, photoUrl: $photoUrl, createdAt: $createdAt, updatedAt: $updatedAt, items: $items, tags: $tags, location: $location}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'location_latitude': location.latitude,
      'location_longitude': location.longitude,
      'location_label': location.label,
      'location_address': location.address,
    };
  }

  factory Container.fromJson(
    Map<String, dynamic> json,
    List<String> tags,
    List<Item> items,
  ) {
    return Container(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: items,
      location: Location(
        latitude: json['location_latitude'] as double,
        longitude: json['location_longitude'] as double,
        label: json['location_label'] as String,
        address: json['location_address'] as String,
      ),
      tags: tags,
    );
  }
}
