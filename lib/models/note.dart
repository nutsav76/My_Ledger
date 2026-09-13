import 'dart:convert';

class Note {
  final String id;
  final String title;
  final String content;
  final String date;
  final String financialYear;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.financialYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'financialYear': financialYear,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      financialYear: map['financialYear'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));
}
