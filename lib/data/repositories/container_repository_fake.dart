import 'dart:io';

import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';

class ContainerRepositoryFake implements ContainerRepository {
  final List<Container> _containers = [
    Container(
      id: '1',
      name: 'Kitchen Supplies',
      photoUrl: null,
      tags: ['kitchen', 'essentials'],
      location: Location(
        latitude: 30.044,
        longitude: 31.2357,
        label: 'Kitchen Cupboard',
        address: '123 Street, City',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      items: [
        Item(
          id: '1',
          name: 'Spare Spatula',
          description: 'An extra spatula I have in case the current one breaks',
          containerId: '1',
          tags: ['tool', 'kitchen'],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Item(
          id: '2',
          name: 'Kitchen Knife Set',
          containerId: '1',
          photoUrl:
              'https://m.media-amazon.com/images/I/81dIS4ecWfL._AC_UF1000,1000_QL80_.jpg',
          tags: ['tool', 'kitchen'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
    ),
    Container(
      id: '2',
      name: 'Office Supplies',
      photoUrl:
          'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
      tags: ['office', 'work'],
      location: Location(
        latitude: 30.050,
        longitude: 31.2400,
        label: 'Home Office',
        address: '123 Street, City',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      items: [
        Item(
          id: '3',
          name: 'Stapler',
          containerId: '2',
          tags: ['office', 'tool'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Item(
          id: '4',
          name: 'Paper Clips',
          containerId: '2',
          tags: ['office', 'supplies'],
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
        Item(
          id: '5',
          name: 'Notebook',
          containerId: '2',
          tags: ['office', 'stationery'],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    ),
    Container(
      id: '3',
      name: 'Toolbox',
      photoUrl:
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400',
      tags: ['tools', 'hardware'],
      location: Location(
        latitude: 30.055,
        longitude: 31.2450,
        label: 'Garage',
        address: '123 Street, City',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      items: [
        Item(
          id: '6',
          name: 'Hammer',
          containerId: '3',
          tags: ['tool', 'hardware'],
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Item(
          id: '7',
          name: 'Screwdriver Set',
          containerId: '3',
          tags: ['tool', 'hardware'],
          createdAt: DateTime.now().subtract(const Duration(days: 9)),
          updatedAt: DateTime.now().subtract(const Duration(days: 9)),
        ),
      ],
    ),
    Container(
      id: '4',
      name: 'Books Collection',
      photoUrl:
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
      tags: ['books', 'reading'],
      location: Location(
        latitude: 30.060,
        longitude: 31.2500,
        label: 'Living Room',
        address: '123 Street, City',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        Item(
          id: '8',
          name: 'Programming Book',
          containerId: '4',
          tags: ['book', 'tech'],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Item(
          id: '9',
          name: 'Design Patterns',
          containerId: '4',
          tags: ['book', 'tech'],
          createdAt: DateTime.now().subtract(const Duration(days: 11)),
          updatedAt: DateTime.now().subtract(const Duration(days: 11)),
        ),
        Item(
          id: '10',
          name: 'Flutter Guide',
          containerId: '4',
          tags: ['book', 'tech'],
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ],
    ),
    Container(
      id: '5',
      name: 'Electronics',
      photoUrl:
          'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
      tags: ['electronics', 'tech'],
      location: Location(
        latitude: 30.065,
        longitude: 31.2550,
        label: 'Storage Room',
        address: '123 Street, City',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      items: [
        Item(
          id: '11',
          name: 'USB Cable',
          containerId: '5',
          tags: ['electronics', 'cable'],
          createdAt: DateTime.now().subtract(const Duration(days: 13)),
          updatedAt: DateTime.now().subtract(const Duration(days: 13)),
        ),
        Item(
          id: '12',
          name: 'Power Adapter',
          containerId: '5',
          tags: ['electronics', 'power'],
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
          updatedAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ],
    ),
  ];

  @override
  Future<List<Container>> fetchContainers() async {
    return List.from(_containers);
  }

  @override
  Future createContainer(Container container) async {
    _containers.add(container);
  }

  @override
  Future deleteContainer(String id) async {
    _containers.removeWhere((c) => c.id == id);
  }

  @override
  Future<Container> fetchContainerById(String id) async {
    return _containers.firstWhere((c) => c.id == id);
  }

  @override
  Future<List<Container>> searchContainers(String query) async {
    if (query.isEmpty) return List.from(_containers);

    return _containers
        .where((c) =>
          c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.location.address.toLowerCase().contains(query.toLowerCase()) ||
          c.location.label.toLowerCase().contains(query.toLowerCase()) ||
          c.tags.any(
                  (t) => t.toLowerCase().contains(query.toLowerCase())
          )
        ).toList();
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    final List<Item> allItems = _containers.expand((c) => c.items).toList();
    if (query.isEmpty) return allItems;

    return allItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  Future updateContainer(Container container) async {
    final index = _containers.indexWhere((c) => c.id == container.id);
    if (index != -1) {
      _containers[index] = container;
    }
  }

  @override
  Future<int> getTotalContainerCount() async {
    return _containers.length;
  }

  @override
  Future<int> getTotalItemCount() async {
    return _containers.fold<int>(0, (acc, container) => acc + container.items.length);
  }

  @override
  Future<List<Container>> fetchRecentContainers(int amount) async {
    final sortContainers = List.of(_containers);
    sortContainers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortContainers.take(amount).toList();
  }
}
