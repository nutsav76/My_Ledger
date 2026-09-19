import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import '../models/transaction.dart';
import '../models/party.dart';

class DataService {
  static Future<void> exportToExcel() async {
    final excel = Excel.createExcel();
    
    // Transactions Sheet
    final Sheet transactionSheet = excel['Transactions'];
    transactionSheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Date'),
      TextCellValue('Particular'),
      TextCellValue('Amount'),
      TextCellValue('Type'),
      TextCellValue('Financial Year'),
    ]);
    
    final fyList = await StorageService.getFinancialYears();
    for (var fy in fyList) {
      final transactions = await StorageService.getTransactions(fy);
      for (var t in transactions) {
        transactionSheet.appendRow([
          TextCellValue(t.id),
          TextCellValue(t.date),
          TextCellValue(t.particular),
          DoubleCellValue(t.amount),
          TextCellValue(t.type.name),
          TextCellValue(t.financialYear),
        ]);
      }
    }

    // Parties Sheet
    final Sheet partySheet = excel['Parties'];
    partySheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Name'),
      TextCellValue('Contact'),
      TextCellValue('Email'),
      TextCellValue('Opening Balance'),
      TextCellValue('Type'),
      TextCellValue('Financial Year'),
    ]);
    
    for (var fy in fyList) {
      final parties = await StorageService.getParties(fy);
      for (var p in parties) {
        partySheet.appendRow([
          TextCellValue(p.id),
          TextCellValue(p.name),
          TextCellValue(p.contact),
          TextCellValue(p.email),
          DoubleCellValue(p.openingBalance),
          TextCellValue(p.type.name),
          TextCellValue(fy),
        ]);
      }
    }

    // Ledger Sheet
    final Sheet ledgerSheet = excel['Ledger'];
    ledgerSheet.appendRow([
      TextCellValue('Party Name'),
      TextCellValue('Date'),
      TextCellValue('Particular'),
      TextCellValue('Debit'),
      TextCellValue('Credit'),
    ]);
    for (var fy in fyList) {
      final parties = await StorageService.getParties(fy);
      for (var p in parties) {
        final ledger = await StorageService.getPartyLedger(p.id);
        for (var entry in ledger) {
          ledgerSheet.appendRow([
            TextCellValue(p.name),
            TextCellValue(entry.date),
            TextCellValue(entry.particular),
            DoubleCellValue(entry.debit),
            DoubleCellValue(entry.credit),
          ]);
        }
      }
    }

    final fileBytes = excel.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_ledger_export.xlsx');
    await file.writeAsBytes(fileBytes!);
    
    await Share.shareXFiles([XFile(file.path)], text: 'My Ledger Data Export (Excel)');
  }

  static Future<void> exportToPdf() async {
    final pdf = pw.Document();
    final fyList = await StorageService.getFinancialYears();

    List<List<String>> allParties = [];
    List<List<String>> allTransactions = [];

    for (var fy in fyList) {
      final parties = await StorageService.getParties(fy);
      for (var p in parties) {
        allParties.add([p.name, p.contact, p.email, p.openingBalance.toString(), fy]);
      }

      final txs = await StorageService.getTransactions(fy);
      for (var t in txs) {
        allTransactions.add([
          t.date,
          t.particular,
          t.amount.toString(),
          t.type.name,
          t.financialYear
        ]);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
              child: pw.Text('MY LEDGER SUMMARY REPORT',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Text('Parties',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Name', 'Contact', 'Email', 'Balance', 'FY'],
              ...allParties,
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Transactions',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Date', 'Particular', 'Amount', 'Type', 'FY'],
              ...allTransactions,
            ],
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_ledger_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)],
        text: 'My Ledger Data Export (PDF)');
  }

  static Future<bool> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = json.decode(content);
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.clear(); // Clear existing data before restore
        
        for (var entry in data.entries) {
          if (entry.value is List) {
            await prefs.setStringList(entry.key, List<String>.from(entry.value));
          } else if (entry.value is String) {
            await prefs.setString(entry.key, entry.value);
          } else if (entry.value is int) {
            await prefs.setInt(entry.key, entry.value);
          } else if (entry.value is double) {
            await prefs.setDouble(entry.key, entry.value);
          } else if (entry.value is bool) {
            await prefs.setBool(entry.key, entry.value);
          }
        }
        return true;
      }
    } catch (e) {
      print('Import Error: $e');
    }
    return false;
  }

  static Future<void> exportToJson() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> data = {};
    for (var key in keys) {
      data[key] = prefs.get(key);
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_ledger_backup.json');
    await file.writeAsString(json.encode(data));
    
    await Share.shareXFiles([XFile(file.path)], text: 'My Ledger Full Backup (JSON)');
  }
}
