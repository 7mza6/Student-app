class UserFields {
  static const String tableName = 'Users';

  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';

  static const String id = 'id';
  static const String email = 'email';
  static const String password = 'Password';
  static const String username = 'username';
  static const String phone = 'phone';
  static const String fullName = 'fullName';
  static const String age = 'age';
  static const String enrolledCourses = 'enrolledCourses';
  static const String notificationSettings = 'notificationSettings';
  static const String tokens = 'tokens';

  static const List<String> values = [
    id,
    email,
    password,
    username,
    phone,
    fullName,
    age,
    enrolledCourses,
    notificationSettings,
    tokens,
  ];
}