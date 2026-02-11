import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:todo_list_app/data/models/habit_model.dart';

class HabitTrackerScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  late Box<Habit> habitBox;
  final TextEditingController _habitNameController = TextEditingController();
  String _selectedCategory = 'Health';

  final List<String> categories = [
    'Health',
    'Productivity',
    'Learning',
    'Fitness',
    'Mindfulness',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    habitBox = Hive.box<Habit>('habits');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Habit Tracker',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            color: Colors.white,
            onPressed: _generatePdfReport,
            tooltip: 'Download PDF Report',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Add New Habit',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: _habitNameController,
                      decoration: InputDecoration(
                        labelText: 'Habit Name',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.addchart_rounded,
                          color: Colors.blue,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addHabit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Text(
                          'Add Habit',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Habits List
          Expanded(
            child: ValueListenableBuilder<Box<Habit>>(
              valueListenable: habitBox.listenable(),
              builder: (context, box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.track_changes, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No habits added yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Start by adding your first habit!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    Habit habit = box.getAt(index)!;
                    return _buildHabitCard(habit, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, int index) {
    final today = DateTime.now();
    final isCompletedToday = habit.isCompletedToday();

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(habit.category),
            shape: BoxShape.circle,
          ),
          child: Icon(_getCategoryIcon(habit.category), color: Colors.white),
        ),
        title: Text(
          habit.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Category: ${habit.category}',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 4),
            Text(
              'Completion: ${(habit.getCompletionRate() * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _toggleHabitCompletion(habit);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompletedToday ? Colors.green : Colors.grey,
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
              child: Icon(
                isCompletedToday ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteHabit(habit),
            ),
          ],
        ),
      ),
    );
  }

  void _addHabit() {
    if (_habitNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Center(
            child: Text(
              'Please Fill Habit Name',
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

    final habit = Habit(
      name: _habitNameController.text,
      category: _selectedCategory,
    );

    habitBox.add(habit);
    _habitNameController.clear();
    setState(() {});
  }

  void _toggleHabitCompletion(Habit habit) {
    final completed = !habit.isCompletedToday();
    habit.markForToday(completed);
    habit.save();
    setState(() {});
  }

  void _deleteHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Delete Habit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        content: Text('Are you sure you want to delete  \nthis habit?'),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () {
              habit.delete();
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: const Color.fromARGB(255, 96, 42, 38),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdfReport() async {
    try {
      final ByteData imageData = await rootBundle.load(
        'assets/splashimage/todologo.png',
      );
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      final pdfImage = pw.MemoryImage(imageBytes);
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 50,
                      height: 50,
                      child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Habit Tracker Report',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'Total Habits Tracked: ${habitBox.length}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Your Habits:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),

                if (habitBox.isEmpty)
                  pw.Text(
                    'No habits added yet',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                  )
                else
                  for (var i = 0; i < habitBox.length; i++)
                    pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.grey300,
                          width: 0.5,
                        ),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                '${i + 1}. ',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  habitBox.getAt(i)!.name,
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Category: ${habitBox.getAt(i)!.category}',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Completion Rate: ${(habitBox.getAt(i)!.getCompletionRate() * 100).toStringAsFixed(1)}%',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            );
          },
        ),
      );

      try {
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename:
              'habit-tracker-report-${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF report generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading image: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Health':
        return Colors.green;
      case 'Productivity':
        return Colors.blue;
      case 'Learning':
        return Colors.purple;
      case 'Fitness':
        return Colors.orange;
      case 'Mindfulness':
        return Colors.teal;
      default:
        return Colors.red;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Health':
        return Icons.health_and_safety;
      case 'Productivity':
        return Icons.work;
      case 'Learning':
        return Icons.school;
      case 'Fitness':
        return Icons.fitness_center;
      case 'Mindfulness':
        return Icons.self_improvement;
      default:
        return Icons.horizontal_split_sharp;
    }
  }
}
