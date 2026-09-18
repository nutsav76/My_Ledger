import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../main.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isObscured = true;
  bool _isRegisterMode = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final lang = languageNotifier.value;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationService.translate('login_error', lang))),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationService.translate('invalid_email', lang))),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationService.translate('password_min_length', lang))),
      );
      return;
    }

    if (_isRegisterMode) {
      final name = _nameController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TranslationService.translate('password_mismatch', lang))),
        );
        return;
      }

      // Register logic
      await StorageService.saveUser(
        email: email,
        password: password,
        name: name,
        imagePath: _imageFile?.path,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationService.translate('register_success', lang))),
      );
      setState(() => _isRegisterMode = false);
    } else {
      // Login logic
      final savedUser = await StorageService.getUser();
      
      bool isSuccess = false;
      if (savedUser != null) {
        if (savedUser['email'] == email && savedUser['password'] == password) {
          isSuccess = true;
        }
      } else if (email == 'admin@admin.com' && password == 'admin1234') {
         isSuccess = true;
         await StorageService.saveUser(email: email, password: password);
      }

      if (isSuccess) {
        await StorageService.setLoggedIn(true);
        final activeFY = await StorageService.getActiveFY() ?? '';
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainShell(activeFY: activeFY)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TranslationService.translate('login_error', lang))),
        );
      }
    }
  }

  void _showForgotPassword() {
    final lang = languageNotifier.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('forgot_password', lang)),
        content: Text(TranslationService.translate('forgot_password_msg', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('close', lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRegisterMode)
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal.shade100,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null 
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.teal) 
                            : null,
                      ),
                    )
                  else
                    const Icon(Icons.account_balance_wallet, size: 80, color: Colors.teal),
                  
                  const SizedBox(height: 16),
                  Text(
                    _isRegisterMode 
                        ? TranslationService.translate('register', lang) 
                        : 'My Ledger',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  if (_isRegisterMode) ...[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: TranslationService.translate('name_label', lang),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: TranslationService.translate('email_label', lang),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: TranslationService.translate('password', lang),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isObscured = !_isObscured),
                      ),
                    ),
                  ),

                  if (_isRegisterMode) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: TranslationService.translate('confirm_password', lang),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_clock),
                      ),
                    ),
                  ],

                  if (!_isRegisterMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPassword,
                        child: Text(TranslationService.translate('forgot_password', lang)),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isRegisterMode 
                        ? TranslationService.translate('register', lang) 
                        : TranslationService.translate('login', lang)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
                    child: Text(_isRegisterMode 
                        ? TranslationService.translate('have_account', lang) 
                        : TranslationService.translate('no_account', lang)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
