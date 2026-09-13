import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../main.dart';
import 'main_shell.dart';
import 'settings_screen.dart';

class FYSelectionScreen extends StatefulWidget {
  const FYSelectionScreen({super.key});

  @override
  State<FYSelectionScreen> createState() => _FYSelectionScreenState();
}

class _FYSelectionScreenState extends State<FYSelectionScreen> {
  List<String> _years = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    final years = await StorageService.getFinancialYears();
    setState(() {
      _years = years;
      _loading = false;
    });
  }

  Future<void> _addYear() async {
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final lang = languageNotifier.value;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('add_fy', lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fromController,
              decoration: InputDecoration(
                  labelText: TranslationService.translate('from_year', lang)),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: toController,
              decoration: InputDecoration(
                  labelText: TranslationService.translate('to_year', lang)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TranslationService.translate('cancel', lang))),
          ElevatedButton(
            onPressed: () async {
              if (fromController.text.isNotEmpty &&
                  toController.text.isNotEmpty) {
                final newYear = '${fromController.text}-${toController.text}';
                if (!_years.contains(newYear)) {
                  setState(() => _years.add(newYear));
                  await StorageService.saveFinancialYears(_years);
                }
                Navigator.pop(context);
              }
            },
            child: Text(TranslationService.translate('save', lang)),
          ),
        ],
      ),
    );
  }

  void _selectYear(String year) async {
    await StorageService.setActiveFY(year);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainShell(activeFY: year)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Ledger'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ).then((_) => _loadYears());
                },
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        TranslationService.translate('select_fy', lang),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _years.length,
                        itemBuilder: (context, index) {
                          final year = _years[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(year),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _selectYear(year),
                              onLongPress: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(TranslationService.translate(
                                        'delete_fy', lang)),
                                    content: Text(
                                        '${TranslationService.translate('delete_confirm_fy', lang)} $year?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(
                                              TranslationService.translate(
                                                  'cancel', lang))),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                            TranslationService.translate(
                                                'delete', lang),
                                            style: const TextStyle(
                                                color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  setState(() => _years.remove(year));
                                  await StorageService.saveFinancialYears(_years);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: _addYear,
                        icon: const Icon(Icons.add),
                        label: Text(TranslationService.translate('add_fy', lang)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
