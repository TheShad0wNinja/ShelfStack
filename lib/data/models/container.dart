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
}
