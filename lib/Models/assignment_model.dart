class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
  });

  factory Assignment.fromMap(Map<String, dynamic> data, String id) {
    return Assignment(
      id: id,
      title: data['title'] ?? '',
      dueDate: DateTime.parse(data['dueDate'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}