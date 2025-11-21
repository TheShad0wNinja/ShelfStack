import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';

abstract class ContainerRepository {
  Future<List<Container>> fetchContainers();

  Future<Container> fetchContainerById(String id);

  Future createContainer(Container container);

  Future updateContainer(Container container);

  Future deleteContainer(String id);

  Future<List<Item>> searchItems(String query);

  Future<List<Container>> searchContainers(String query);
}
