import 'dart:convert';

enum BalanceType { dr, cr }

class Party {
  final String id;
  final String name;
  final String contact;
  final String email;
  final double openingBalance;
  final BalanceType type;

  Party({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.openingBalance,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'openingBalance': openingBalance,
      'type': type.index,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      email: map['email'],
      openingBalance: (map['openingBalance'] as num).toDouble(),
      type: BalanceType.values[map['type']],
    );
  }

  String toJson() => json.encode(toMap());

  factory Party.fromJson(String source) => Party.fromMap(json.decode(source));
}

class PartyTransaction {
  final String id;
  final String partyId;
  final String date;
  final String particular;
  final double debit;
  final double credit;

  PartyTransaction({
    required this.id,
    required this.partyId,
    required this.date,
    required this.particular,
    required this.debit,
    required this.credit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partyId': partyId,
      'date': date,
      'particular': particular,
      'debit': debit,
      'credit': credit,
    };
  }

  factory PartyTransaction.fromMap(Map<String, dynamic> map) {
    return PartyTransaction(
      id: map['id'],
      partyId: map['partyId'],
      date: map['date'],
      particular: map['particular'],
      debit: (map['debit'] as num).toDouble(),
      credit: (map['credit'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PartyTransaction.fromJson(String source) => PartyTransaction.fromMap(json.decode(source));
}
