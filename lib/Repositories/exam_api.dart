import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/exam_model.dart';
import '../Repositories/exam_repository.dart';
import '../services/network_info.dart';
import 'local/exam_local.dart';

class ExamApi implements ExamRepository {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _local = ExamLocal();
  final _uuid = const Uuid();

  DatabaseReference _ref(String courseId) => _database.ref('courses/$courseId/exams');

  @override
  Future<Exam> create(String courseId, Exam exam,{DatabaseExecutor? txn}) async {
    final examWithId = exam.id.isEmpty
        ? exam.copyWith(id: _uuid.v4())
        : exam;

    await _local.create(courseId, examWithId);

    if (await NetworkInfo.isOnline) {
      try {
        await _ref(courseId).child(examWithId.id).set(exam.toMap());
      } catch (e) {
        print("Network error on Exam create, saved locally. Error: $e");
      }
    }
    return examWithId;
  }

  @override
  Future<List<Exam>> readAllForCourse(String courseId) async {
    if (await NetworkInfo.isOnline) {
      try {
        final List<Exam> remoteExams = [];
        final snapshot = await _ref(courseId).get();
        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          data.forEach((id, examData) {
            final map = Map<String, dynamic>.from(examData);
            remoteExams.add(Exam.fromMap(map, id));
          });
        }
        await _local.upsertMany(courseId, remoteExams);
        return remoteExams;
      } catch (e) {
        print("Network error on Exam readAll, falling back to local. Error: $e");
        return _local.readAllForCourse(courseId);
      }
    } else {
      print("Offline: Reading all Exams for course from local DB.");
      return _local.readAllForCourse(courseId);
    }
  }

  @override
  Future<int> update(String courseId, Exam exam) async {
    final localResult = await _local.update(courseId, exam);
    if (await NetworkInfo.isOnline) {
      try {
        await _ref(courseId).child(exam.id).update(exam.toMap());
      } catch (e) {
        print("Network error on Exam update, saved locally. Error: $e");
      }
    }
    return localResult;
  }

  @override
  Future<int> delete(String examId) async {
    return await _local.delete(examId);
  }
}