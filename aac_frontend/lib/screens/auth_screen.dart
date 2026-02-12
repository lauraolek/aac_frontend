import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../constants/app_strings.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    final currentEmail = _emailController.text.trim();
    
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController resetController = TextEditingController(text: currentEmail);
        bool isDialogLoading = false;
        String? dialogErrorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(AppStrings.forgotPassword),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(AppStrings.passwordResetContent),
                  const SizedBox(height: 15),
                  TextField(
                    controller: resetController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppStrings.email,
                      errorText: dialogErrorText,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    onChanged: (_) {
                      if (dialogErrorText != null) {
                        setDialogState(() => dialogErrorText = null);
                      }
                    },
                  ),
                  if (isDialogLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.cancelButton),
                ),
                ElevatedButton(
                  onPressed: isDialogLoading 
                    ? null 
                    : () async {
                        final email = resetController.text.trim();
                        
                        if (email.isEmpty || !email.contains('@')) {
                          setDialogState(() => dialogErrorText = AppStrings.pleaseEnterValidEmail);
                          return;
                        }

                        setDialogState(() => isDialogLoading = true);
                        
                        try {
                          await Provider.of<ProfileProvider>(context, listen: false)
                              .sendPasswordResetEmail(email);
                          
                          if (context.mounted) {
                            Navigator.pop(context); // Close reset input dialog
                            _showSuccessDialog();    // Call the helper below
                          }
                        } catch (e) {
                          setDialogState(() {
                            isDialogLoading = false;
                            dialogErrorText = e.toString();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.passwordResetTitle),
        content: const Text(AppStrings.passwordResetContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.okButton),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    try {
      if (_isLogin) {
        await profileProvider.login(
          _emailController.text,
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.loggedInSuccessfully)),
        );
      } else {
        await profileProvider.register(
          _passwordController.text,
          _emailController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.registeredSuccessfully)),
        );
        setState(() {
          _isLogin = true; // switch to login after successful registration
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.authError}: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLogin ? AppStrings.loginTitle : AppStrings.registerTitle,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin
                          ? AppStrings.welcomeBack
                          : AppStrings.createAccount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppStrings.email,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return AppStrings.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 12) {
                          return AppStrings.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword, // Opens the new dialog
                          child: const Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    const SizedBox(height: 25),
                    profileProvider.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitAuthForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              _isLogin
                                  ? AppStrings.loginButton
                                  : AppStrings.registerButton,
                            ),
                          ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? AppStrings.createAccountPrompt
                            : AppStrings.alreadyHaveAccountPrompt,
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
