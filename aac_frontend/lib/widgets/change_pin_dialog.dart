import 'package:aac_app/constants/app_strings.dart';
import 'package:aac_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  // Use late to ensure we control the lifecycle
  late final TextEditingController _controller;
  String? _firstEntry;
  String? _errorText;
  bool _isVerifyingOld = false;

  @override
  void initState() {
    super.initState();
    // Initialize and explicitly clear to prevent any autofill artifacts
    _controller = TextEditingController();
    _controller.clear(); 
    
    _isVerifyingOld = Provider.of<ProfileProvider>(context, listen: false).hasPin;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final input = _controller.text;

    setState(() => _errorText = null);

    if (_isVerifyingOld) {
      if (provider.verifyPin(input)) {
        setState(() {
          _isVerifyingOld = false;
          _controller.clear();
        });
      } else {
        setState(() => _errorText = AppStrings.oldPinWrong);
      }
    } else if (_firstEntry == null) {
      if (input.length == 4) {
        setState(() {
          _firstEntry = input;
          _controller.clear();
        });
      } else {
        setState(() => _errorText = AppStrings.pinMustBeFourDigits);
      }
    } else {
      if (input == _firstEntry) {
        await provider.updatePin(input);
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _errorText = AppStrings.pinMismatch;
          _firstEntry = null; 
          _controller.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = AppStrings.setupPin;
    String hint = AppStrings.enterNewPin;

    if (_isVerifyingOld) {
      title = AppStrings.enterPinPrompt;
      hint = AppStrings.pinHint;
    } else if (_firstEntry != null) {
      title = AppStrings.confirmNewPin;
      hint = AppStrings.pinHint;
    }

    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
        autofocus: true,
        // Optional: Some browsers ignore 'null', so we give it a dummy hint
        autofillHints: [AutofillHints.newPassword], // Only if 'null' fails
        // This helps prevent browsers and OS autofill from hijacking the field
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hint, 
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text(AppStrings.cancelButton),
        ),
        ElevatedButton(
          onPressed: _handleAction, 
          child: const Text(AppStrings.confirmButton),
        ),
      ],
    );
  }
}