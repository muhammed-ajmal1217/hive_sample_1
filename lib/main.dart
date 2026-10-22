import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_sample/model/student_model.dart';
import 'package:hive_sample/screens/student_screen.dart';
import 'package:hive_sample/services/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(StudentAdapter());

  final studentService = StudentService();
  await studentService.init();

  runApp(StudentApp(service: studentService));
}

class StudentApp extends StatelessWidget {
  final StudentService service;

  const StudentApp({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Hive App',
      debugShowCheckedModeBanner: false,
      home: StudentScreen(service: service),
    );
  }
}
