import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/party.dart';
import '../models/note.dart';

class StorageService {
  static const String _fyKey = 'financial_years';
  static const String _activeFyKey = 'active_financial_year';
  static const String _partyKey = 'parties';
  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'language';
  static const String _dateTypeKey = 'date_type';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  static Future<void> saveUser({
    required String email,
    required String password,
    String? name,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode({
      'email': email,
      'password': password,
      'name': name ?? '',
      'imagePath': imagePath ?? '',
    });
    await prefs.setString(_userKey, data);
  }

  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    final decoded = json.decode(data);
    return {
      'email': decoded['email'] ?? '',
      'password': decoded['password'] ?? '',
      'name': decoded['name'] ?? '',
      'imagePath': decoded['imagePath'] ?? '',
    };
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<List<String>> getFinancialYears() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_fyKey) ?? [];
  }

  static Future<void> saveFinancialYears(List<String> years) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_fyKey, years);
  }

  static Future<String?> getActiveFY() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeFyKey);
  }

  static Future<void> setActiveFY(String fy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeFyKey, fy);
  }

  // Transactions
  static Future<List<Transaction>> getTransactions(String fy) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transactions_$fy');
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => Transaction.fromMap(e)).toList();
  }

  static Future<void> saveTransactions(String fy, List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(transactions.map((e) => e.toMap()).toList());
    await prefs.setString('transactions_$fy', data);
  }

  static Future<double> getPartyBalance(Party party) async {
    final ledger = await getPartyLedger(party.id);
    double balance = party.openingBalance * (party.type == BalanceType.dr ? 1 : -1);
    for (var entry in ledger) {
      balance += (entry.debit - entry.credit);
    }
    return balance;
  }

  // Parties
  static Future<List<Party>> getParties(String fy) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('parties_$fy');
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => Party.fromMap(e)).toList();
  }

  static Future<void> saveParties(String fy, List<Party> parties) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(parties.map((e) => e.toMap()).toList());
    await prefs.setString('parties_$fy', data);
  }

  static Future<List<PartyTransaction>> getPartyLedger(String partyId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('ledger_$partyId');
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => PartyTransaction.fromMap(e)).toList();
  }

  static Future<void> savePartyLedger(String partyId, List<PartyTransaction> ledger) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(ledger.map((e) => e.toMap()).toList());
    await prefs.setString('ledger_$partyId', data);
  }

  // Notes
  static Future<List<Note>> getNotes(String fy) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes_$fy');
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => Note.fromMap(e)).toList();
  }

  static Future<void> saveNotes(String fy, List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(notes.map((e) => e.toMap()).toList());
    await prefs.setString('notes_$fy', data);
  }

  // Settings
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'English';
  }

  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }

  static Future<String> getDateType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dateTypeKey) ?? 'AD';
  }

  static Future<void> saveDateType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateTypeKey, type);
  }
}
