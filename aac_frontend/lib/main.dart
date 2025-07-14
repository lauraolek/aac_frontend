import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/category.dart';
import 'providers/communication_provider.dart';
import 'screens/category_grid_screen.dart';
import 'screens/item_list_screen.dart';
import 'widgets/sentence_builder_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CommunicationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAC App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainAppScreen(),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

final String appBarTitle = 'TODO: nimi';

class _MainAppScreenState extends State<MainAppScreen> {
  Widget? _currentBody;
  String _currentAppBarTitle = appBarTitle;
  bool _showBackButton = false;

  @override
  void initState() {
    super.initState();
    _currentBody = CategoryGridScreen(onNavigateToItems: _navigateToCategoryItems);
  }

  void _navigateToCategoryItems(Category category) {
    setState(() {
      _currentBody = ItemListScreen(category: category, onNavigateBack: _navigateBackToCategories);
      _currentAppBarTitle = category.name;
      _showBackButton = true;
    });
  }

  void _navigateBackToCategories() {
    setState(() {
      _currentBody = CategoryGridScreen(onNavigateToItems: _navigateToCategoryItems);
      _currentAppBarTitle = appBarTitle;
      _showBackButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentAppBarTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        leading: _showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBackToCategories,
              )
            : null,
      ),
      body: _currentBody,
      bottomNavigationBar: const SentenceBuilderBar(), // persistent
    );
  }
}