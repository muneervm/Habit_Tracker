import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/screens/addtask_screen.dart';
import 'package:todo_list_app/widgets/progress_indicator.dart'; // Import your widget
import 'package:todo_list_app/widgets/sizeconfig.dart';

class Welcomepage extends StatefulWidget {
  const Welcomepage({super.key});

  @override
  State<Welcomepage> createState() => _WelcomepageState();
}

class _WelcomepageState extends State<Welcomepage> {
  bool _isLoading = false;

  void _navigateToAddTask() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => AddTaskScreen()));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/baground.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 6.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: SizeConfig.screenHeight * 1 / 4),
                  Container(
                    child: SizedBox(
                      height: SizeConfig.blockHeight * 40,
                      width: SizeConfig.blockWidth * 100,
                      child: Image.asset('assets/iconintro.png'),
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * .5),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: SizeConfig.blockHeight * 3.8,
                        fontWeight: FontWeight.w600,
                      ),
                      children: const [
                        TextSpan(
                          text: "Hello ",
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(
                          text: "Again!",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 1.5),
                  Text(
                    "Let's Complete Your Tasks",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: SizeConfig.blockHeight * 1.8,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 4.5),
                  Center(
                    child: SizedBox(
                      width: SizeConfig.blockWidth * 85,
                      height: SizeConfig.blockHeight * 5.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isLoading ? null : _navigateToAddTask,
                        child: _isLoading
                            ? const Progresscircle()
                            : Text(
                                "Get Ready",
                                style: GoogleFonts.poppins(
                                  fontSize: SizeConfig.blockHeight * 1.8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
