import '../models/child_profile.dart';
import '../models/category.dart';
import '../models/communication_item.dart';
import '../data/app_data.dart';

/// This service holds data in-memory and provides asynchronous methods
/// that mimic network requests. It's designed to be replaced by a real
/// backend integration later.
class ApiService {
  static final List<ChildProfile> _mockChildProfiles = [];

  // Start after initial dummy data
  static int _nextChildId = 3;
  static int _nextCategoryId = 4;
  static int _nextItemId = 10;

  ApiService() {
    if (_mockChildProfiles.isEmpty) {
      _initializeDummyData();
    }
  }

  void _initializeDummyData() {
    print('ApiService: Initializing dummy data...');
    _mockChildProfiles.clear();
    for (var profile in initialDummyProfiles) {
      // create deep copies to ensure original dummy data isn't directly modified
      _mockChildProfiles.add(
        ChildProfile(
          id: profile.id,
          name: profile.name,
          categories: profile.categories
              .map(
                (cat) => Category(
                  id: cat.id,
                  name: cat.name,
                  imageUrl: cat.imageUrl,
                  items: cat.items
                      .map(
                        (item) => CommunicationItem(
                          id: item.id,
                          word: item.word,
                          imageUrl: item.imageUrl,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      );
    }
    print(
      'ApiService: Dummy data initialized with ${_mockChildProfiles.length} profiles.',
    );
  }

  // --- Child Profile Operations ---

  Future<List<ChildProfile>> fetchChildProfiles() async {
    print('ApiService: Simulating fetching child profiles...');

    return _mockChildProfiles.map((profile) => profile.copyWith()).toList();
    // TODO
  }

  Future<void> addChildProfile(ChildProfile profile) async {
    print('ApiService: Simulating adding child profile: ${profile.name}');
    _mockChildProfiles.add(profile.copyWith());
    _nextChildId++;
    print(
      'ApiService: Child profile "${profile.name}" added with ID ${profile.id}.',
    );
    // TODO
  }

  Future<void> deleteChildProfile(int childId) async {
    print('ApiService: Simulating deleting child profile with ID: $childId');
    _mockChildProfiles.removeWhere((profile) => profile.id == childId);
    print('ApiService: Child profile with ID "$childId" deleted.');
    // TODO
  }

  // --- Category Operations ---

  Future<void> addCategory(
    int childId,
    String categoryName,
    String imageUrl,
  ) async {
    print(
      'ApiService: Simulating adding category "$categoryName" for child $childId',
    );

    final childIndex = _mockChildProfiles.indexWhere(
      (profile) => profile.id == childId,
    );
    if (childIndex != -1) {
      final newCategory = Category(
        id: _nextCategoryId++,
        name: categoryName,
        imageUrl: imageUrl,
        items: [],
      );
      final updatedCategories = List<Category>.from(
        _mockChildProfiles[childIndex].categories,
      )..add(newCategory);
      _mockChildProfiles[childIndex] = _mockChildProfiles[childIndex].copyWith(
        categories: updatedCategories,
      );
      print(
        'ApiService: Category "$categoryName" added for child $childId with ID ${newCategory.id}.',
      );
    } else {
      print(
        'ApiService Error: Child with ID $childId not found to add category.',
      );
    }
    // TODO
  }

  Future<void> deleteCategory(int childId, int categoryId) async {
    print(
      'ApiService: Simulating deleting category $categoryId for child $childId',
    );

    final childIndex = _mockChildProfiles.indexWhere(
      (profile) => profile.id == childId,
    );
    if (childIndex != -1) {
      final updatedCategories = _mockChildProfiles[childIndex].categories
          .where((cat) => cat.id != categoryId)
          .toList();
      _mockChildProfiles[childIndex] = _mockChildProfiles[childIndex].copyWith(
        categories: updatedCategories,
      );
      print('ApiService: Category "$categoryId" deleted for child $childId.');
    } else {
      print(
        'ApiService Error: Child with ID $childId not found to delete category.',
      );
    }
    // TODO
  }

  Future<void> editCategory(
    int childId,
    int categoryId,
    String newName,
    String newImageUrl,
  ) async {
    print(
      'ApiService: Simulating editing category $categoryId for child $childId',
    );

    final childIndex = _mockChildProfiles.indexWhere(
      (profile) => profile.id == childId,
    );
    if (childIndex != -1) {
      final updatedCategories = _mockChildProfiles[childIndex].categories.map((
        category,
      ) {
        if (category.id == categoryId) {
          return category.copyWith(name: newName, imageUrl: newImageUrl);
        }
        return category;
      }).toList();
      _mockChildProfiles[childIndex] = _mockChildProfiles[childIndex].copyWith(
        categories: updatedCategories,
      );
      print('ApiService: Category "$categoryId" edited for child $childId.');
    } else {
      print(
        'ApiService Error: Child with ID $childId not found to edit category.',
      );
    }
    // TODO
  }

  // --- Item Operations ---

  Future<void> addItemToCategory(
    int childId,
    int categoryId,
    CommunicationItem item,
  ) async {
    print(
      'ApiService: Simulating adding item "${item.word}" to category $categoryId for child $childId',
    );

    final childIndex = _mockChildProfiles.indexWhere(
      (profile) => profile.id == childId,
    );
    if (childIndex != -1) {
      final categoryIndex = _mockChildProfiles[childIndex].categories
          .indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex != -1) {
        final currentCategory =
            _mockChildProfiles[childIndex].categories[categoryIndex];

        final updatedItems = List<CommunicationItem>.from(currentCategory.items)
          ..add(item.copyWith());
        final updatedCategory = currentCategory.copyWith(items: updatedItems);

        final updatedCategories = List<Category>.from(
          _mockChildProfiles[childIndex].categories,
        );
        updatedCategories[categoryIndex] = updatedCategory;

        _mockChildProfiles[childIndex] = _mockChildProfiles[childIndex]
            .copyWith(categories: updatedCategories);
        _nextItemId++;
        print(
          'ApiService: Item "${item.word}" added to category $categoryId for child $childId with ID ${item.id}.',
        );
      } else {
        print(
          'ApiService Error: Category with ID $categoryId not found for child $childId to add item.',
        );
      }
    } else {
      print('ApiService Error: Child with ID $childId not found to add item.');
    }
    // TODO
  }

  Future<void> deleteItemFromCategory(
    int childId,
    int categoryId,
    int itemId,
  ) async {
    print(
      'ApiService: Simulating deleting item $itemId from category $categoryId for child $childId',
    );

    final childIndex = _mockChildProfiles.indexWhere(
      (profile) => profile.id == childId,
    );
    if (childIndex != -1) {
      final categoryIndex = _mockChildProfiles[childIndex].categories
          .indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex != -1) {
        final currentCategory =
            _mockChildProfiles[childIndex].categories[categoryIndex];
        final updatedItems = currentCategory.items
            .where((item) => item.id != itemId)
            .toList();
        final updatedCategory = currentCategory.copyWith(items: updatedItems);

        final updatedCategories = List<Category>.from(
          _mockChildProfiles[childIndex].categories,
        );
        updatedCategories[categoryIndex] = updatedCategory;

        _mockChildProfiles[childIndex] = _mockChildProfiles[childIndex]
            .copyWith(categories: updatedCategories);
        print(
          'ApiService: Item "$itemId" deleted from category $categoryId for child $childId.',
        );
      } else {
        print(
          'ApiService Error: Category with ID $categoryId not found for child $childId to delete item.',
        );
      }
    } else {
      print(
        'ApiService Error: Child with ID $childId not found to delete item.',
      );
    }
    // TODO
  }

  Future<void> editItemInCategory(
    int childId,
    int categoryId,
    int itemId,
    String newWord,
    String newImageUrl,
  ) async {
    print(
      'ApiService: Simulating editing item $itemId in category $categoryId for child $childId...',
    );

    final childIndex = _mockChildProfiles.indexWhere(
      (profile) => profile.id == childId,
    );
    if (childIndex != -1) {
      final categoryIndex = _mockChildProfiles[childIndex].categories
          .indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex != -1) {
        final currentCategory =
            _mockChildProfiles[childIndex].categories[categoryIndex];
        final updatedItems = currentCategory.items.map((item) {
          if (item.id == itemId) {
            return CommunicationItem(
              id: item.id,
              word: newWord,
              imageUrl: newImageUrl,
            );
          }
          return item;
        }).toList();
        final updatedCategory = currentCategory.copyWith(items: updatedItems);

        final updatedCategories = List<Category>.from(
          _mockChildProfiles[childIndex].categories,
        );
        updatedCategories[categoryIndex] = updatedCategory;

        _mockChildProfiles[childIndex] = _mockChildProfiles[childIndex]
            .copyWith(categories: updatedCategories);
        print(
          'ApiService: Item "$itemId" edited in category $categoryId for child $childId.',
        );
      } else {
        print(
          'ApiService Error: Category with ID $categoryId not found for child $childId to edit item.',
        );
      }
    } else {
      print('ApiService Error: Child with ID $childId not found to edit item.');
    }
    // TODO
  }
}
