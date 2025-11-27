import 'package:sqflite/sqflite.dart';

class DatabaseSeeder {
  static Future<void> seed(Database db) async {
    print('seeding');
    final now = DateTime.now();

    // Seed containers
    await db.insert('containers', {
      'id': '1',
      'name': 'Kitchen Supplies',
      'photo_url': null,
      'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      'updated_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      'location_latitude': 30.044,
      'location_longitude': 31.2357,
      'location_label': 'Kitchen Cupboard',
      'location_address': '123 Street, City',
    });

    await db.insert('containers', {
      'id': '2',
      'name': 'Office Supplies',
      'photo_url':
          'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
      'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      'updated_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
      'location_latitude': 30.050,
      'location_longitude': 31.2400,
      'location_label': 'Home Office',
      'location_address': '123 Street, City',
    });

    await db.insert('containers', {
      'id': '3',
      'name': 'Toolbox',
      'photo_url':
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400',
      'created_at': now.subtract(const Duration(days: 15)).toIso8601String(),
      'updated_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
      'location_latitude': 30.055,
      'location_longitude': 31.2450,
      'location_label': 'Garage',
      'location_address': '123 Street, City',
    });

    await db.insert('containers', {
      'id': '4',
      'name': 'Books Collection',
      'photo_url':
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
      'created_at': now.subtract(const Duration(days: 20)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      'location_latitude': 30.060,
      'location_longitude': 31.2500,
      'location_label': 'Living Room',
      'location_address': '123 Street, City',
    });

    await db.insert('containers', {
      'id': '5',
      'name': 'Electronics',
      'photo_url':
          'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
      'created_at': now.subtract(const Duration(days: 25)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      'location_latitude': 30.065,
      'location_longitude': 31.2550,
      'location_label': 'Storage Room',
      'location_address': '123 Street, City',
    });

    // Seed container tags
    final containerTags = [
      {'container_id': '1', 'tag': 'kitchen'},
      {'container_id': '1', 'tag': 'essentials'},
      {'container_id': '2', 'tag': 'office'},
      {'container_id': '2', 'tag': 'work'},
      {'container_id': '3', 'tag': 'tools'},
      {'container_id': '3', 'tag': 'hardware'},
      {'container_id': '4', 'tag': 'books'},
      {'container_id': '4', 'tag': 'reading'},
      {'container_id': '5', 'tag': 'electronics'},
      {'container_id': '5', 'tag': 'tech'},
    ];

    for (final tag in containerTags) {
      await db.insert('container_tags', tag);
    }

    // Seed items
    await db.insert('items', {
      'id': '1',
      'name': 'Spare Spatula',
      'description': 'An extra spatula I have in case the current one breaks',
      'photo_url': null,
      'container_id': '1',
      'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '2',
      'name': 'Kitchen Knife Set',
      'description': null,
      'photo_url':
          'https://m.media-amazon.com/images/I/81dIS4ecWfL._AC_UF1000,1000_QL80_.jpg',
      'container_id': '1',
      'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 3)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '3',
      'name': 'Stapler',
      'description': null,
      'photo_url': null,
      'container_id': '2',
      'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 5)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '4',
      'name': 'Paper Clips',
      'description': null,
      'photo_url': null,
      'container_id': '2',
      'created_at': now.subtract(const Duration(days: 6)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 6)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '5',
      'name': 'Notebook',
      'description': null,
      'photo_url': null,
      'container_id': '2',
      'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 7)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '6',
      'name': 'Hammer',
      'description': null,
      'photo_url': null,
      'container_id': '3',
      'created_at': now.subtract(const Duration(days: 8)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 8)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '7',
      'name': 'Screwdriver Set',
      'description': null,
      'photo_url': null,
      'container_id': '3',
      'created_at': now.subtract(const Duration(days: 9)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 9)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '8',
      'name': 'Programming Book',
      'description': null,
      'photo_url': null,
      'container_id': '4',
      'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 10)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '9',
      'name': 'Design Patterns',
      'description': 'A book on how to implement computer science design patterns correctly',
      'photo_url': null,
      'container_id': '4',
      'created_at': now.subtract(const Duration(days: 11)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 11)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '10',
      'name': 'Flutter Guide',
      'description': null,
      'photo_url': null,
      'container_id': '4',
      'created_at': now.subtract(const Duration(days: 12)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 12)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '11',
      'name': 'USB Cable',
      'description': null,
      'photo_url': null,
      'container_id': '5',
      'created_at': now.subtract(const Duration(days: 13)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 13)).toIso8601String(),
    });

    await db.insert('items', {
      'id': '12',
      'name': 'Power Adapter',
      'description': null,
      'photo_url': null,
      'container_id': '5',
      'created_at': now.subtract(const Duration(days: 14)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 14)).toIso8601String(),
    });

    // Seed item tags
    final itemTags = [
      {'item_id': '1', 'tag': 'tool'},
      {'item_id': '1', 'tag': 'kitchen'},
      {'item_id': '2', 'tag': 'tool'},
      {'item_id': '2', 'tag': 'kitchen'},
      {'item_id': '3', 'tag': 'office'},
      {'item_id': '3', 'tag': 'tool'},
      {'item_id': '4', 'tag': 'office'},
      {'item_id': '4', 'tag': 'supplies'},
      {'item_id': '5', 'tag': 'office'},
      {'item_id': '5', 'tag': 'stationery'},
      {'item_id': '6', 'tag': 'tool'},
      {'item_id': '6', 'tag': 'hardware'},
      {'item_id': '7', 'tag': 'tool'},
      {'item_id': '7', 'tag': 'hardware'},
      {'item_id': '8', 'tag': 'book'},
      {'item_id': '8', 'tag': 'tech'},
      {'item_id': '9', 'tag': 'book'},
      {'item_id': '9', 'tag': 'tech'},
      {'item_id': '10', 'tag': 'book'},
      {'item_id': '10', 'tag': 'tech'},
      {'item_id': '11', 'tag': 'electronics'},
      {'item_id': '11', 'tag': 'cable'},
      {'item_id': '12', 'tag': 'electronics'},
      {'item_id': '12', 'tag': 'power'},
    ];

    for (final tag in itemTags) {
      await db.insert('item_tags', tag);
    }

    print('DatabaseSeeder: Database seeded successfully.');
  }
}
