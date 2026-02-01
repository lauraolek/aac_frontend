import 'package:aac_app/constants/app_strings.dart';
import 'package:aac_app/providers/profile_provider.dart';
import 'package:aac_app/widgets/change_pin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.child_care),
            title: const Text(AppStrings.childMode),
            subtitle: const Text(AppStrings.childModeDescription),
            value: provider.isChildMode,
            onChanged: (bool value) async {
              if (value) {
                if (!provider.hasPin) {
                  // 1. Show the dialog and WAIT for it to close
                  await showDialog(
                    context: context,
                    builder: (context) => const ChangePinDialog(),
                  );

                  // 2. Re-check if the PIN was successfully set
                  if (provider.hasPin) {
                    provider.setChildMode(true);
                    // Optional: Auto-exit settings to show the locked main screen
                    if (context.mounted) Navigator.pop(context);
                  }
                } else {
                  provider.setChildMode(true);
                  Navigator.pop(context);
                }
              } else {
                // Turning off usually happens via the Lock icon on MainScreen,
                // but we handle it here for consistency.
                provider.setChildMode(false);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text(AppStrings.changePin),
            onTap: () => showDialog(
              context: context,
              builder: (context) => const ChangePinDialog(),
            ),
          ),
        ],
      ),
    );
  }
}