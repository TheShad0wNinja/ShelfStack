import 'package:shelfstack/data/datasources/fake_database.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';

class ContainerRepositoryFake implements ContainerRepository {
  final _db = FakeDatabase();

  @override
  Future<List<Container>> fetchContainers() async {
    return List.from(_db.containers);
  }

  @override
  Future createContainer(Container container) async {
    _db.containers.add(container);
  }

  @override
  Future deleteContainer(String id) async {
    _db.containers.removeWhere((c) => c.id == id);
  }

  @override
  Future<Container> fetchContainerById(String id) async {
    return _db.containers.firstWhere((c) => c.id == id);
  }

  @override
  Future<List<Container>> searchContainers(String query) async {
    if (query.isEmpty) return List.from(_db.containers);

    return _db.containers
        .where(
          (c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.location.address.toLowerCase().contains(query.toLowerCase()) ||
              c.location.label.toLowerCase().contains(query.toLowerCase()) ||
              c.tags.any((t) => t.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
  }

  @override
  Future updateContainer(Container container) async {
    final index = _db.containers.indexWhere((c) => c.id == container.id);
    if (index != -1) {
      _db.containers[index] = container;
    }
  }

  @override
  Future<int> fetchTotalContainerCount() async {
    return _db.containers.length;
  }

  @override
  Future<List<Container>> fetchRecentContainers(int amount) async {
    final sortContainers = List.of(_db.containers);
    sortContainers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortContainers.take(amount).toList();
  }
}
