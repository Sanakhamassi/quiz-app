import 'package:flutter/material.dart';
import 'package:mentimeter_clone/screens/code_screen.dart';
import 'package:mentimeter_clone/screens/gere_quiz.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("./assets/images/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              "assets/images/icon.png",
              height: 64,
              width: 64,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              "Think It Fast",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 50,
                  color: Colors.black),
            ),
          ]),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CodeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(250, 40),
              primary: const Color.fromARGB(255, 26, 108, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text('Start Quiz'),
          ),
          const SizedBox(
            width: 80,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const manageQuiz()),
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(250, 40),
              primary: Color.fromARGB(255, 26, 108, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text('Manage Quiz'),
          ),
        ],
      )),
    ));
    ;
  }
}
