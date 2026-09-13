import 'package:flutter/material.dart';
import '../main.dart';
import '../services/translation_service.dart';
import 'home_screen.dart';
import 'transaction_screen.dart';
import 'party_screen.dart';
import 'note_screen.dart';

class MainShell extends StatefulWidget {
  final String activeFY;
  const MainShell({super.key, required this.activeFY});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(activeFY: widget.activeFY, key: UniqueKey()),
              TransactionScreen(activeFY: widget.activeFY),
              PartyScreen(activeFY: widget.activeFY),
              NoteScreen(activeFY: widget.activeFY),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: TranslationService.translate('home', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long),
                label: TranslationService.translate('transaction', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people),
                label: TranslationService.translate('party', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.note),
                label: TranslationService.translate('note', lang),
              ),
            ],
          ),
        );
      },
    );
  }
}
