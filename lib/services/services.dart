import 'package:hive/hive.dart';
import 'package:hive_sample/model/student_model.dart';

class StudentService {
  static const String boxName = 'students';

  late Box<Student> _studentBox;

  Future<void> init() async {
    _studentBox = await Hive.openBox<Student>(boxName);
  }

  List<Student> getAllStudents() {
    return _studentBox.values.toList();
  }

  Future<void> addStudent(Student student) async {
    await _studentBox.add(student);
  }

  Future<void> updateStudent(
    Student student,
    String name,
    int age,
    String studentClass,
  ) async {
    student.name = name;
    student.age = age;
    student.studentClass = studentClass;

    await student.save();
  }

  Future<void> deleteStudent(Student student) async {
    await student.delete();
  }
}
