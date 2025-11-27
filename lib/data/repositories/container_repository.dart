import 'package:shelfstack/data/models/container.dart';

abstract class ContainerRepository {
  Stream<void> get onDataChanged;

  Future<List<Container>> fetchContainers();

  Future<Container> fetchContainerById(String id);

  Future createContainer(Container container);

  Future updateContainer(Container container);

  Future deleteContainer(String id);

  Future<List<Container>> searchContainers(String query);

  Future<int> fetchTotalContainerCount();

  Future<List<Container>> fetchRecentContainers(int amount);
}
