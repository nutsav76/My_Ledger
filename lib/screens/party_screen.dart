import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart' as ndp;
import 'package:share_plus/share_plus.dart';
import '../services/storage_service.dart';
import '../models/party.dart';
import '../services/translation_service.dart';
import '../main.dart';

class PartyScreen extends StatefulWidget {
  final String activeFY;
  const PartyScreen({super.key, required this.activeFY});

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  List<Party> _parties = [];
  Map<String, double> _balances = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final parties = await StorageService.getParties();
    Map<String, double> balances = {};
    for (var p in parties) {
      balances[p.id] = await StorageService.getPartyBalance(p);
    }
    setState(() {
      _parties = parties;
      _balances = balances;
      _loading = false;
    });
  }

  Future<void> _addParty() async {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();
    final balanceController = TextEditingController();
    BalanceType selectedType = BalanceType.dr;
    final lang = languageNotifier.value;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(TranslationService.translate('add_party', lang)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: TranslationService.translate('name', lang))),
                TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                        labelText:
                            TranslationService.translate('contact', lang))),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: TranslationService.translate('email', lang))),
                TextField(
                    controller: balanceController,
                    decoration: InputDecoration(
                        labelText: TranslationService.translate(
                            'opening_balance', lang)),
                    keyboardType: TextInputType.number),
                Row(
                  children: [
                    Text('${TranslationService.translate('type', lang)}: '),
                    Radio<BalanceType>(
                        value: BalanceType.dr,
                        groupValue: selectedType,
                        onChanged: (v) => setDialogState(() => selectedType = v!)),
                    Text(TranslationService.translate('debit', lang)),
                    Radio<BalanceType>(
                        value: BalanceType.cr,
                        groupValue: selectedType,
                        onChanged: (v) => setDialogState(() => selectedType = v!)),
                    Text(TranslationService.translate('credit', lang)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(TranslationService.translate('cancel', lang))),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final newParty = Party(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    contact: contactController.text,
                    email: emailController.text,
                    openingBalance:
                        double.tryParse(balanceController.text) ?? 0,
                    type: selectedType,
                  );
                  setState(() => _parties.add(newParty));
                  await StorageService.saveParties(_parties);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(TranslationService.translate('save', lang)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: AppBar(
              title: Text(TranslationService.translate('parties', lang))),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _parties.length,
                  itemBuilder: (context, index) {
                    final party = _parties[index];
                    final balance = _balances[party.id] ?? 0;
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(party.name),
                      subtitle: Text('${party.contact} | ${party.email}'),
                      trailing: Text(
                        '${balance.abs()} ${balance >= 0 ? TranslationService.translate('debit', lang) : TranslationService.translate('credit', lang)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: balance >= 0 ? Colors.teal : Colors.red,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PartyLedgerScreen(party: party)),
                      ).then((_) => _loadData()),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addParty,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class PartyLedgerScreen extends StatefulWidget {
  final Party party;
  const PartyLedgerScreen({super.key, required this.party});

  @override
  State<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends State<PartyLedgerScreen> {
  List<PartyTransaction> _ledger = [];
  bool _loading = true;
  String _dateType = 'AD';

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    final ledger = await StorageService.getPartyLedger(widget.party.id);
    final dateType = await StorageService.getDateType();
    setState(() {
      _ledger = ledger;
      _dateType = dateType;
      _loading = false;
    });
  }

  Future<void> _addEntry() async {
    final particularController = TextEditingController();
    final amountController = TextEditingController();
    String selectedEntryType = 'Debit'; // Default
    DateTime selectedDate = DateTime.now();
    ndp.NepaliDateTime selectedNepaliDate = ndp.NepaliDateTime.now();
    final lang = languageNotifier.value;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(TranslationService.translate('add_ledger_entry', lang)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: particularController,
                    decoration: InputDecoration(
                        labelText:
                            TranslationService.translate('particular', lang))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedEntryType,
                  decoration: InputDecoration(
                      labelText: TranslationService.translate('type', lang)),
                  items: ['Debit', 'Credit']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(TranslationService.translate(
                                type.toLowerCase(), lang)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setDialogState(() => selectedEntryType = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                        labelText: TranslationService.translate('amount', lang)),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(_dateType == 'AD'
                      ? '${TranslationService.translate('date', lang)}: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'
                      : '${TranslationService.translate('date', lang)}: ${selectedNepaliDate.format('yyyy-MM-dd')}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    if (_dateType == 'AD') {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null)
                        setDialogState(() => selectedDate = picked);
                    } else {
                      final picked = await ndp.showNepaliDatePicker(
                        context: context,
                        initialDate: selectedNepaliDate,
                        firstDate: ndp.NepaliDateTime(2000),
                        lastDate: ndp.NepaliDateTime.now(),
                      );
                      if (picked != null)
                        setDialogState(() => selectedNepaliDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(TranslationService.translate('cancel', lang))),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) return;

                final newEntry = PartyTransaction(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  partyId: widget.party.id,
                  date: _dateType == 'AD'
                      ? DateFormat('yyyy-MM-dd').format(selectedDate)
                      : selectedNepaliDate.format('yyyy-MM-dd'),
                  particular: particularController.text,
                  debit: selectedEntryType == 'Debit' ? amount : 0,
                  credit: selectedEntryType == 'Credit' ? amount : 0,
                );
                setState(() => _ledger.add(newEntry));
                await StorageService.savePartyLedger(widget.party.id, _ledger);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(TranslationService.translate('save', lang)),
            ),
          ],
        ),
      ),
    );
  }

  void _shareLedger(double opening, String lang) {
    String content =
        '${TranslationService.translate('ledger', lang)}: ${widget.party.name}\n';
    content +=
        '${TranslationService.translate('opening_balance', lang)}: ${widget.party.openingBalance} ${widget.party.type == BalanceType.dr ? TranslationService.translate('debit', lang) : TranslationService.translate('credit', lang)}\n\n';
    content +=
        '${TranslationService.translate('date', lang)} | ${TranslationService.translate('particular', lang)} | ${TranslationService.translate('debit', lang)} | ${TranslationService.translate('credit', lang)} | ${TranslationService.translate('balance', lang)}\n';
    content += '------------------------------------------------\n';

    double running = opening;
    for (var e in _ledger) {
      running += (e.debit - e.credit);
      content +=
          '${e.date} | ${e.particular} | ${e.debit} | ${e.credit} | ${running.abs()} ${running >= 0 ? TranslationService.translate('debit', lang) : TranslationService.translate('credit', lang)}\n';
    }

    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    double runningBalance = widget.party.openingBalance *
        (widget.party.type == BalanceType.dr ? 1 : -1);
    final initialRunningBalance = runningBalance;

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
                '${TranslationService.translate('ledger', lang)}: ${widget.party.name}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareLedger(initialRunningBalance, lang),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text(
                                TranslationService.translate('date', lang))),
                        DataColumn(
                            label: Text(TranslationService.translate(
                                'particular', lang))),
                        DataColumn(
                            label: Text(
                                TranslationService.translate('debit', lang))),
                        DataColumn(
                            label: Text(
                                TranslationService.translate('credit', lang))),
                        DataColumn(
                            label: Text(
                                TranslationService.translate('balance', lang))),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('-')),
                          DataCell(Text(TranslationService.translate(
                              'opening_balance', lang))),
                          DataCell(Text(widget.party.type == BalanceType.dr
                              ? widget.party.openingBalance.toString()
                              : '0')),
                          DataCell(Text(widget.party.type == BalanceType.cr
                              ? widget.party.openingBalance.toString()
                              : '0')),
                          DataCell(Text(
                              '${widget.party.openingBalance} ${widget.party.type == BalanceType.dr ? TranslationService.translate('debit', lang) : TranslationService.translate('credit', lang)}')),
                        ]),
                        ..._ledger.map((e) {
                          runningBalance += (e.debit - e.credit);
                          return DataRow(cells: [
                            DataCell(Text(e.date)),
                            DataCell(Text(e.particular)),
                            DataCell(Text(e.debit.toString())),
                            DataCell(Text(e.credit.toString())),
                            DataCell(Text(
                                '${runningBalance.abs()} ${runningBalance >= 0 ? TranslationService.translate('debit', lang) : TranslationService.translate('credit', lang)}')),
                          ]);
                        }),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addEntry,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
