import '../models/category.dart';
import '../models/communication_item.dart';

final List<Category> dummyCategories = [
  Category(
    id: 'cat_001',
    name: 'Tegevused',
    imageUrl: '',
    items: [
      CommunicationItem(
          id: 'item_001',
          word: 'Sööma',
          imageUrl: ''),
      CommunicationItem(
          id: 'item_002',
          word: 'Jooma',
          imageUrl: ''),
      CommunicationItem(
          id: 'item_003',
          word: 'Mängima',
          imageUrl: ''),
    ],
  ),
  Category(
    id: 'cat_002',
    name: 'Tunded',
    imageUrl: '',
    items: [
      CommunicationItem(
          id: 'item_006',
          word: 'Rõõmus',
          imageUrl: ''),
      CommunicationItem(
          id: 'item_007',
          word: 'Kurb',
          imageUrl: ''),
      CommunicationItem(
          id: 'item_008',
          word: 'Vihane',
          imageUrl: ''),
    ],
  ),
  Category(
    id: 'cat_003',
    name: 'Toit',
    imageUrl: '',
    items: [
      CommunicationItem(
          id: 'item_010',
          word: 'Õun',
          imageUrl: ''),
      CommunicationItem(
          id: 'item_011',
          word: 'Banaan',
          imageUrl: ''),
      CommunicationItem(
          id: 'item_013',
          word: 'Leib',
          imageUrl: ''),
    ],
  ),
];
