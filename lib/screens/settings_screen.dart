import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart' as ndp;
import 'package:nepali_utils/nepali_utils.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../services/data_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _dateType = 'AD';
  String _language = 'English';
  String _themeMode = 'system';
  List<String> _years = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dateType = await StorageService.getDateType();
    final language = await StorageService.getLanguage();
    final theme = await StorageService.getThemeMode();
    final years = await StorageService.getFinancialYears();
    setState(() {
      _dateType = dateType;
      _language = language;
      _themeMode = theme;
      _years = years;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: AppBar(
              title: Text(TranslationService.translate('settings', lang))),
          body: ListView(
            children: [
              _buildSectionHeader(
                  TranslationService.translate('date_calendar', lang)),
              ListTile(
                title: Text(TranslationService.translate('calendar_format', lang)),
                subtitle: Text(_dateType),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final newType = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(
                          TranslationService.translate('select_format', lang)),
                      children: ['AD', 'BS']
                          .map((e) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, e),
                                child: Text(e),
                              ))
                          .toList(),
                    ),
                  );
                  if (newType != null) {
                    await StorageService.saveDateType(newType);
                    setState(() => _dateType = newType);
                    dateTypeNotifier.value = newType;
                  }
                },
              ),
              const Divider(),
              _buildSectionHeader(
                  TranslationService.translate('financial_year', lang)),
              ListTile(
                title: Text(
                    TranslationService.translate('manage_fy', lang)),
                subtitle: Text('${_years.length} ${TranslationService.translate('years_added', lang)}'),
                onTap: () {},
              ),
              const Divider(),
              _buildSectionHeader(
                  TranslationService.translate('language', lang)),
              ListTile(
                title: Text(TranslationService.translate('app_language', lang)),
                subtitle: Text(_language),
                onTap: () async {
                  final newLang = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(
                          TranslationService.translate('select_language', lang)),
                      children: [
                        'Nepali',
                        'English',
                        'Japanese',
                        'Chinese',
                        'Hindi',
                        'Korean',
                        'French',
                        'Spanish',
                        'German',
                        'Arabic',
                        'Finnish'
                      ]
                          .map((e) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, e),
                                child: Text(e),
                              ))
                          .toList(),
                    ),
                  );
                  if (newLang != null) {
                    await StorageService.saveLanguage(newLang);
                    setState(() => _language = newLang);
                    languageNotifier.value = newLang;
                  }
                },
              ),
              const Divider(),
              _buildSectionHeader(
                  TranslationService.translate('appearance', lang)),
              ListTile(
                title: Text(TranslationService.translate('theme_mode', lang)),
                subtitle: Text(_themeMode),
                onTap: () async {
                  final newTheme = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(
                          TranslationService.translate('select_theme', lang)),
                      children: ['light', 'dark', 'system']
                          .map((e) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, e),
                                child: Text(e),
                              ))
                          .toList(),
                    ),
                  );
                  if (newTheme != null) {
                    await StorageService.saveThemeMode(newTheme);
                    setState(() => _themeMode = newTheme);
                    if (newTheme == 'light') {
                      themeNotifier.value = ThemeMode.light;
                    } else if (newTheme == 'dark') {
                      themeNotifier.value = ThemeMode.dark;
                    } else {
                      themeNotifier.value = ThemeMode.system;
                    }
                  }
                },
              ),
              const Divider(),
              _buildSectionHeader(
                  TranslationService.translate('backup_restore', lang)),
              ListTile(
                leading: const Icon(Icons.table_view, color: Colors.green),
                title: Text(TranslationService.translate('export_excel', lang)),
                onTap: () => DataService.exportToExcel(),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(TranslationService.translate('export_pdf', lang)),
                onTap: () => DataService.exportToPdf(),
              ),
              ListTile(
                leading: const Icon(Icons.backup, color: Colors.blue),
                title: Text('Export JSON (Full Backup)', style: TextStyle(color: Colors.blue)),
                onTap: () => DataService.exportToJson(),
              ),
              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.orange),
                title: Text(TranslationService.translate('import_data', lang)),
                onTap: () async {
                  final success = await DataService.importData();
                  if (!mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data restored successfully! Please restart the app.')),
                    );
                    _loadSettings();
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
