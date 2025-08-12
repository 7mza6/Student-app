class CourseFields {
  static const String tableName = 'Courses';

  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String realType = 'REAL NOT NULL'; // For storing doubles like progress

  static const String id = '_id';
  static const String icon = 'icon';
  static const String title = 'title';
  static const String status = 'status';
  static const String progress = 'progress';

  static const List<String> values = [
    id,
    icon,
    title,
    status,
    progress,
  ];
}