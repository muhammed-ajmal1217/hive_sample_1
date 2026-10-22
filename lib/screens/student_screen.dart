import 'package:flutter/material.dart';
import 'package:hive_sample/model/student_model.dart';
import 'package:hive_sample/services/services.dart';
import 'package:hive_sample/widgets/student_card.dart';
import 'package:hive_sample/widgets/student_form.dart';

class StudentScreen extends StatefulWidget {
  final StudentService service;

  const StudentScreen({super.key, required this.service});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      _students = widget.service.getAllStudents();
    });
  }

  Future<void> _showStudentForm({Student? student}) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StudentForm(
          student: student,
          onSave: (name, age, studentClass) async {
            try {
              if (student == null) {
                await widget.service.addStudent(
                  Student(name: name, age: age, studentClass: studentClass),
                );
              } else {
                await widget.service.updateStudent(
                  student,
                  name,
                  age,
                  studentClass,
                );
              }

              if (!mounted) return;

              Navigator.of(dialogContext).pop();
              _loadStudents();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    student == null
                        ? 'Student added successfully'
                        : 'Student updated successfully',
                  ),
                ),
              );
            } catch (error) {
              if (!dialogContext.mounted) return;

              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('Failed to save student: $error')),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _deleteStudent(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await widget.service.deleteStudent(student);

    if (!mounted) return;

    _loadStudents();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        centerTitle: true,
      ),
      body: _students.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No students found', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 4),
                  Text('Tap + to add your first student'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];

                return StudentCard(
                  student: student,
                  onEdit: () => _showStudentForm(student: student),
                  onDelete: () => _deleteStudent(student),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentForm(),
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
