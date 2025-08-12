class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
  });

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    int? submissionsCount,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  factory Assignment.fromMap(Map<String, dynamic> data, String id) {
    return Assignment(
      id: id,
      title: data['title'] ?? 'Untitled Assignment',
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