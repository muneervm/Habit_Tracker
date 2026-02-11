import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:todo_list_app/data/models/hivemodel.dart';
import 'package:todo_list_app/screens/tasklist_screen.dart';
import 'package:todo_list_app/widgets/progress_indicator.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late Box<Task> taskBox;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  DateTime? selectedDate;
  bool _isAddingTask = false;

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          'Add New Task',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt_rounded, color: Colors.white),
            tooltip: 'View Tasks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskListScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            TextField(
              controller: titleController,
              decoration: _inputDecoration('Enter Task Title'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 1,
              decoration: _inputDecoration('Enter Task Description'),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: dueDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: _inputDecoration('Select due date').copyWith(
                prefixIcon: const Icon(Icons.date_range, color: Colors.black),
              ),
            ),

            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: _isAddingTask ? null : _addTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: _isAddingTask
                  ? const Progresscircle()
                  : const Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 25),

            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/taskdoneimage/doingtask.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dueDateController.text =
            "${picked.day.toString().padLeft(2, '0')}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.year}";
      });
    }
  }

  void _addTask() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Center(
            child: Text(
              'Please fill all fields',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 191, 50, 40),
        ),
      );
      return;
    }

    setState(() {
      _isAddingTask = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    taskBox.add(
      Task(
        title: titleController.text,
        description: descriptionController.text,
        dueDate: dueDateController.text,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Center(
          child: Text(
            'Task added successfully!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
    );

    setState(() {
      titleController.clear();
      descriptionController.clear();
      dueDateController.clear();
      selectedDate = null;
      _isAddingTask = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }
}
