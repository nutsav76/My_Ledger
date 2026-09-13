import 'package:flutter/material.dart';
import 'screens/fy_selection_screen.dart';
import 'services/storage_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<String> languageNotifier = ValueNotifier('English');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final theme = await StorageService.getThemeMode();
  if (theme == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else if (theme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  }

  final lang = await StorageService.getLanguage();
  languageNotifier.value = lang;

  runApp(const MyLedgerApp());
}

class MyLedgerApp extends StatelessWidget {
  const MyLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'My Ledger',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: const FYSelectionScreen(),
        );
      },
    );
  }
}
