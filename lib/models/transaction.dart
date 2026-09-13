import 'dart:convert';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String date;
  final String particular;
  final double amount;
  final TransactionType type;
  final String financialYear;

  Transaction({
    required this.id,
    required this.date,
    required this.particular,
    required this.amount,
    required this.type,
    required this.financialYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'particular': particular,
      'amount': amount,
      'type': type.index,
      'financialYear': financialYear,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      date: map['date'],
      particular: map['particular'],
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values[map['type']],
      financialYear: map['financialYear'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source));
}
