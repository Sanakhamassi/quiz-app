import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:mentimeter_clone/screens/startQuiz.dart';

import 'package:mentimeter_clone/widgets/flash_message_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  TextEditingController controllerCode = TextEditingController();
  String code = '';
  final _codeSaisit = true;
  TextStyle defaultStyle = const TextStyle(color: Colors.grey, fontSize: 12.0);
  TextStyle linkStyle = const TextStyle(color: Colors.blue);
  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Wrap(
            spacing: 15, // to apply margin in the main axis of the wrap
            runSpacing: 15,
            alignment: WrapAlignment.center,
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
                  "Think It Fast Admin",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                      color: Colors.black),
                ),
              ]),
              const Text(
                "Please enter the code",
                style: TextStyle(
                    color: Color.fromARGB(255, 11, 11, 33), fontSize: 20),
              ),
              SizedBox(
                width: 350,
                height: 40,
                child: TextField(
                  controller: controllerCode,

                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // Only numbers can be entered
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '**** ****',
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    code = controllerCode.text;
                    //snapshots gives us a stream which is a dart object which emits new data whenever the source changes
                    FirebaseFirestore.instance
                        .collection('Quiz')
                        .get()
                        .then((value) {
                      value.docs.forEach((element) async {
                        if (code == element.id) {
                          // Get a reference to the collection
                          CollectionReference collectionReference =
                              FirebaseFirestore.instance
                                  .collection('QuizSession');
                          // Add a new document to the collection with a generated ID
                          DocumentReference docRef =
                              await collectionReference.add({
                            'idQuiz': code,
                            'nbMax': 10,
                            'State': 'wait',
                          });
                          String sessionDocId = docRef.id;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    StartQuiz(code, sessionDocId)),
                          );
                        }
                      });
                    });
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: FlashMessageWidget("Invalid code", Colors.red),
                    //   behavior: SnackBarBehavior.floating,
                    //   backgroundColor: Colors.transparent,
                    //   elevation: 0,
                    // ));
                  },
                  child: const Text("Start Quiz"),
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(350, 50),
                      primary: Colors.blue, // Set the background color
                      onPrimary: Colors.white, // Set the text color
                      elevation: 0, // Remove the default elevation
                      shape: RoundedRectangleBorder(
                        // Set the shape of the button
                        borderRadius: BorderRadius.circular(2),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ))),
            ]),
      ),
    );
  }
}
