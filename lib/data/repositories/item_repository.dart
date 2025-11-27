import 'package:shelfstack/data/models/item.dart';

abstract class ItemRepository {
  Stream<void> get onDataChanged;

  Future<List<Item>> fetchItemsByContainerId(String containerId);

  Future<Item> fetchItemById(String id);

  Future createItem(Item item);

  Future updateItem(Item item);

  Future deleteItem(String id);

  Future<List<Item>> searchItems(String query);

  Future<int> fetchTotalItemCount();

  Future assignItemToContainer(String itemId, String containerId);

  Future moveItemToContainer(
    String itemId,
    String fromContainerId,
    String toContainerId,
  );
}
