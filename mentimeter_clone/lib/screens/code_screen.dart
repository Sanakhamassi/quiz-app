import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:mentimeter_clone/screens/name_screen.dart';

import 'package:mentimeter_clone/widgets/flash_message_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key, required this.title});

  final String title;

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
                  "Think It Fast",
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 40,
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
                      value.docs.forEach((element) {
                        if (code == element.id) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NameScreen(code)),
                          );
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: FlashMessageWidget(
                                errormsg: "Code invalid, try again"),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ));
                        }
                      });
                    });
                  },
                  child: const Text("Submit"),
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
              const Text("The code is found in the screen in front of you"),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     RichText(
              //       text: TextSpan(
              //         style: defaultStyle,
              //         children: <TextSpan>[
              //           const TextSpan(text: 'Create your own Menti at '),
              //           TextSpan(
              //               text: 'mentimeter.com',
              //               style: linkStyle,
              //               recognizer: TapGestureRecognizer()
              //                 ..onTap = () {
              //                   launchURL('https://www.mentimeter.com/');
              //                 }),
              //         ],
              //       ),
              //     ),
              //   ],
              // )
            ]),
      ),
    );
  }
}
