import 'package:aac_app/constants/app_strings.dart';
import 'package:aac_app/models/profile.dart';
import 'package:aac_app/providers/profile_provider.dart';
import 'package:aac_app/screens/settings_screen.dart';
import 'package:aac_app/services/api_service.dart';
import 'package:aac_app/widgets/add_profile_dialog.dart';
import 'package:aac_app/widgets/change_pin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
          create: (context) =>
              CommunicationProvider(context.read<ApiService>()),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
  Category? _selectedCategory;
  String _currentAppBarTitle = AppStrings.appTitle;
  bool _showBackButton = false;

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('http://www.arasaac.org');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _navigateToCategoryItems(Category category) {
    setState(() {
      _selectedCategory = category;
      _currentAppBarTitle = category.name;
      _showBackButton = true;
    });
  }

  void _navigateBackToCategories() {
    setState(() {
      _selectedCategory = null;
      _currentAppBarTitle = AppStrings.appTitle;
      _showBackButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    Widget body;
    if (profileProvider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_selectedCategory != null) {
      body = ItemListScreen(
        category: _selectedCategory!,
        onNavigateBack: _navigateBackToCategories,
      );
    } else {
      body = CategoryGridScreen(
        onNavigateToItems: _navigateToCategoryItems,
        isReadOnly: profileProvider.isChildMode,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          profileProvider.activeProfile != null
              ? '${_currentAppBarTitle} - ${profileProvider.activeProfile!.name}'
              : _currentAppBarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        leading: _showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBackToCategories,
              )
            : null,
        actions: [
          if (profileProvider.isChildMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.lock_outline,
                  color: Colors.orangeAccent,
                ),
                onPressed: () => _showExitDialog(context, profileProvider),
              ),
            ),
          if (!profileProvider.isChildMode) ...[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: AppStrings.settings,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await profileProvider.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.loggedOutSuccessfully),
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        decoration: BoxDecoration(color: Colors.blue.shade700),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.profiles,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.activeProfile != null
                                  ? '${AppStrings.activeProfile}: ${provider.activeProfile!.name}'
                                  : AppStrings.noActiveProfile,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...provider.profiles.map((profile) {
                        return ListTile(
                          leading: Icon(
                            profile.id == provider.activeProfile?.id
                                ? Icons.person_pin
                                : Icons.person_outline,
                            color: profile.id == provider.activeProfile?.id
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          title: Text(profile.name),
                          onTap: () {
                            provider.setActiveProfile(profile);
                            _navigateBackToCategories();
                            Navigator.pop(context);
                          },
                          trailing: profileProvider.isChildMode
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text(
                                          AppStrings.deleteProfile,
                                        ),
                                        content: Text(
                                          AppStrings.deleteProfileConfirmation(
                                            profile.name,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            child: const Text(
                                              AppStrings.cancelButton,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await provider.deleteProfile(
                                                profile.id!,
                                              );
                                              Navigator.pop(dialogContext);

                                              if (provider.activeProfile ==
                                                      null &&
                                                  provider
                                                      .profiles
                                                      .isNotEmpty) {
                                                provider.setActiveProfile(
                                                  provider.profiles.first,
                                                );
                                              } else if (provider
                                                  .profiles
                                                  .isEmpty) {
                                                provider.setActiveProfile(null);
                                                _navigateBackToCategories();
                                              }
                                            },
                                            child: const Text(
                                              AppStrings.deleteButton,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        );
                      }).toList(),
                      const Divider(),
                      if (!profileProvider.isChildMode)
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text(AppStrings.addProfile),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AddProfileDialog(
                                onAddProfile: (name) async {
                                  final newProfile = Profile(
                                    name: name,
                                    categories: [],
                                  );
                                  await provider.addProfile(newProfile);
                                  _navigateBackToCategories();
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // --- BRANDING & ATTRIBUTION FOOTER ---
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'images/logo_ARASAAC.png',
                        height: 50,
                        filterQuality: FilterQuality.medium,
                        isAntiAlias: true,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _launchURL, // Calls the method you just added
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontFamily: 'Inter',
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "Piktogrammide autor: Sergio Palao. Päritolu: ",
                              ),
                              TextSpan(
                                text: "ARASAAC (http://www.arasaac.org)",
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ". Litsents: CC (BY-NC-SA). Omanik: Aragóni valitsus (Hispaania).",
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: body,
      bottomNavigationBar: const SentenceBuilderBar(),
    );
  }

  void _showExitDialog(BuildContext context, ProfileProvider provider) {
    final pinController = TextEditingController(); // Always fresh/empty

    showDialog(
      context: context,
      builder: (context) {
        String? errorMessage;
        bool isSendingEmail = false;
        bool emailSentSuccessfully = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 1. Success View: Shown after email is sent
            if (emailSentSuccessfully) {
              return AlertDialog(
                title: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48,
                ),
                content: const Text(
                  AppStrings.pinResetSent,
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(AppStrings.okButton),
                  ),
                ],
              );
            }
            // 2. Default View: The PIN entry form
            return AlertDialog(
              title: const Text(AppStrings.exitChildModeTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: AppStrings.pinHint,
                      errorText: errorMessage,
                      counterText: "",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Forgot PIN Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: isSendingEmail
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () async {
                              setDialogState(() => isSendingEmail = true);
                              final success = await provider
                                  .requestNewPinEmail();

                              if (success) {
                                setDialogState(
                                  () => emailSentSuccessfully = true,
                                );
                              } else {
                                setDialogState(() {
                                  isSendingEmail = false;
                                  errorMessage = AppStrings.pinResetFailed;
                                });
                              }
                            },
                            child: const Text(
                              AppStrings.forgotPin,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.cancelButton),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (provider.verifyPin(pinController.text)) {
                      provider.setChildMode(false);
                      Navigator.pop(context);
                    } else {
                      setDialogState(() {
                        errorMessage = AppStrings.wrongPinError;
                        pinController.clear();
                      });
                    }
                  },
                  child: const Text(AppStrings.confirmButton),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
