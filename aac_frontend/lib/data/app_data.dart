import 'package:aac_app/models/child_profile.dart';

import '../models/category.dart';
import '../models/communication_item.dart';

final List<Category> dummyCategories = [
  Category(
    id: 1,
    name: 'Tegevused',
    imageUrl: '',
    items: [
      CommunicationItem(
          id: 1,
          word: 'Sööma',
          imageUrl: ''),
      CommunicationItem(
          id: 2,
          word: 'Jooma',
          imageUrl: ''),
      CommunicationItem(
          id: 3,
          word: 'Mängima',
          imageUrl: ''),
    ],
  ),
  Category(
    id: 2,
    name: 'Tunded',
    imageUrl: '',
    items: [
      CommunicationItem(
          id: 4,
          word: 'Rõõmus',
          imageUrl: ''),
      CommunicationItem(
          id: 5,
          word: 'Kurb',
          imageUrl: ''),
      CommunicationItem(
          id: 6,
          word: 'Vihane',
          imageUrl: ''),
    ],
  ),
  Category(
    id: 3,
    name: 'Toit',
    imageUrl: '',
    items: [
      CommunicationItem(
          id: 7,
          word: 'Õun',
          imageUrl: ''),
      CommunicationItem(
          id: 8,
          word: 'Banaan',
          imageUrl: ''),
      CommunicationItem(
          id: 9,
          word: 'Leib',
          imageUrl: ''),
    ],
  ),
];

final List<ChildProfile> initialDummyProfiles = [
  ChildProfile(
    id: 1,
    name: 'Sarah',
    categories: List.from(dummyCategories),
  ),
  ChildProfile(
    id: 2,
    name: 'John',
    categories: [],
  ),
];