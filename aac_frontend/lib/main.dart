import 'package:aac_app/constants/app_strings.dart';
import 'package:aac_app/models/child_profile.dart';
import 'package:aac_app/providers/profile_provider.dart';
import 'package:aac_app/services/api_service.dart';
import 'package:aac_app/widgets/add_child_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/category.dart';
import 'providers/communication_provider.dart';
import 'screens/category_grid_screen.dart';
import 'screens/item_list_screen.dart';
import 'widgets/sentence_builder_bar.dart';
import 'screens/auth_screen.dart';

void main() {
runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProxyProvider<ApiService, ProfileProvider>(
          create: (context) => ProfileProvider(context.read<ApiService>()),
          update: (context, apiService, previousProfileProvider) =>
              previousProfileProvider!..apiService = apiService,
        ),
        ChangeNotifierProxyProvider<ApiService, CommunicationProvider>(
          create: (context) => CommunicationProvider(context.read<ApiService>()),
          update: (context, apiService, previousCommunicationProvider) =>
              previousCommunicationProvider!..apiService = apiService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          color: Colors.blue.shade700,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue.shade700,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),
      home: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (!profileProvider.isAuthenticated) {
            return AuthScreen();
          }
          return MainAppScreen();
        },
      ),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  Widget? _currentBody;
  String _currentAppBarTitle = AppStrings.appTitle;
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
      _currentAppBarTitle = AppStrings.appTitle;
      _showBackButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(profileProvider.activeChild != null
              ? '${_currentAppBarTitle} - ${profileProvider.activeChild!.name}'
              : _currentAppBarTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await profileProvider.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.loggedOutSuccessfully)),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.childProfiles,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.activeChild != null
                            ? '${AppStrings.activeChild}: ${provider.activeChild!.name}'
                            : AppStrings.noActiveChild,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppStrings.loggedInAs}: ${provider.userId ?? AppStrings.notLoggedIn}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ...provider.childProfiles.map((profile) {
                  return ListTile(
                    leading: Icon(
                      profile.id == provider.activeChild?.id
                          ? Icons.person_pin
                          : Icons.person_outline,
                      color: profile.id == provider.activeChild?.id
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    title: Text(profile.name),
                    onTap: () {
                      provider.setActiveChild(profile);
                      _navigateBackToCategories();
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text(AppStrings.deleteChildProfile),
                            content: Text(AppStrings.deleteChildConfirmation(profile.name)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(AppStrings.cancelButton),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await provider.deleteChild(profile.id!);
                                  Navigator.pop(dialogContext);

                                  if (provider.activeChild == null && provider.childProfiles.isNotEmpty) {
                                    provider.setActiveChild(provider.childProfiles.first);
                                  } else if (provider.childProfiles.isEmpty) {
                                    provider.setActiveChild(null);
                                    _navigateBackToCategories();
                                  }
                                },
                                child: const Text(AppStrings.deleteButton),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text(AppStrings.addChildProfile),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AddChildDialog(
                        onAddChild: (name) async {
                          final newChild = ChildProfile(name: name, categories: []);
                          await provider.addChild(newChild);
                          _navigateBackToCategories();
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _currentBody!;
        },
      ),
      bottomNavigationBar: const SentenceBuilderBar(),
    );
  }
}