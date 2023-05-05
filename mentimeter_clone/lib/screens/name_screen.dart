import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mentimeter_clone/screens/Score_Screen.dart';
import 'package:mentimeter_clone/screens/quiz_screen.dart';
import 'package:mentimeter_clone/screens/waiting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/flash_message_widget.dart';

class NameScreen extends StatefulWidget {
  String code;
  NameScreen(this.code, {Key? key}) : super(key: key);

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  String pseudoName = '';
  String sessionId = '';
  int nbmax = 0;
  int nbPlayers = 0;
  TextEditingController controllerName = TextEditingController();

  Future<void> addData() async {
    pseudoName = controllerName.text;
    // Get a reference to the collections
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('Player');
    CollectionReference collectionSessionquiz =
        FirebaseFirestore.instance.collection('QuizSession');

    // Add a new player to the collection Player with a generated ID
    DocumentReference docRef = await collectionReference.add({
      'playerName': pseudoName,
      'playerRank': 0,
      'playerScore': 0,
    });
    String docId = docRef.id;

    collectionSessionquiz.get().then((value) {
      value.docs.forEach((element) async {
        if (widget.code == element.get('idQuiz')) {
          setState(() {
            nbPlayers++;
            sessionId = element.id;
            nbmax = element.get('nbMax');
          });
          await collectionSessionquiz.doc(element.id).update({
            'Players': FieldValue.arrayUnion([docId]),
          });
          if (nbPlayers == nbmax) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: FlashMessageWidget(errormsg: "Quiz reached max player"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ));
          } else if (element.get('State') == 'wait') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WaitingScreen(sessionId, widget.code, docId)),
            );
          } else if (element.get('State') == 'start') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Quiz(widget.code, sessionId, docId)),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 75, 235),
          title: Text("Name screen"),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("./assets/images/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 10,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: controllerName,
                            decoration: const InputDecoration(
                                labelText: 'Tap your pseudo name'),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () => addData(),
                              child: const Text("Start"),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(200, 30),
                                  primary: Color.fromARGB(255, 15, 75,
                                      235), // Set the background color
                                  onPrimary: Colors.white, // Set the text color
                                  elevation: 0, // Remove the default elevation
                                  shape: RoundedRectangleBorder(
                                    // Set the shape of the button
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  )))
                        ],
                      )),
                    ),
                  ))),
        ));
  }
}
