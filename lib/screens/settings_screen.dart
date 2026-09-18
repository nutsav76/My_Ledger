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
                  if (success && mounted) {
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

  void _showConverter(String lang) {
    showDialog(
      context: context,
      builder: (context) => _DateConverterDialog(lang: lang),
    );
  }
}

class _DateConverterDialog extends StatefulWidget {
  final String lang;
  const _DateConverterDialog({required this.lang});

  @override
  State<_DateConverterDialog> createState() => _DateConverterDialogState();
}

class _DateConverterDialogState extends State<_DateConverterDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedAdDate = DateTime.now();
  ndp.NepaliDateTime _selectedBsDate = ndp.NepaliDateTime.now();
  String _result = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _convertAdToBs() {
    setState(() {
      final nepaliDate = _selectedAdDate.toNepaliDateTime();
      _result = nepaliDate.format('yyyy-MM-dd');
    });
  }

  void _convertBsToAd() {
    setState(() {
      final adDate = _selectedBsDate.toDateTime();
      _result = '${adDate.year}-${adDate.month.toString().padLeft(2, '0')}-${adDate.day.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(TranslationService.translate('date_converter', widget.lang)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: TranslationService.translate('ad_to_bs', widget.lang)),
                Tab(text: TranslationService.translate('bs_to_ad', widget.lang)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // AD to BS
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedAdDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _selectedAdDate = date);
                            _convertAdToBs();
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text('${_selectedAdDate.year}-${_selectedAdDate.month}-${_selectedAdDate.day}'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${TranslationService.translate('result', widget.lang)}: $_result',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // BS to AD
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final date = await ndp.showNepaliDatePicker(
                            context: context,
                            initialDate: _selectedBsDate,
                            firstDate: ndp.NepaliDateTime(2000),
                            lastDate: ndp.NepaliDateTime(2099),
                          );
                          if (date != null) {
                            setState(() => _selectedBsDate = date);
                            _convertBsToAd();
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_selectedBsDate.format('yyyy-MM-dd')),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${TranslationService.translate('result', widget.lang)}: $_result',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(TranslationService.translate('close', widget.lang)),
        ),
      ],
    );
  }
}
