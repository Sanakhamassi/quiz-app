import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mentimeter_clone/screens/quiz_screen.dart';
import 'package:mentimeter_clone/widgets/answerBox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaitingScreen extends StatefulWidget {
  String sessionId = '';
  String code;
  String playerId;
  WaitingScreen(this.sessionId, this.code, this.playerId, {Key? key})
      : super(key: key);

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  CollectionReference session =
      FirebaseFirestore.instance.collection('QuizSession');
  bool _isLoading = false;

  Future<void> gotoQuiz() async {
    setState(() {
      _isLoading = true;
    });

    DocumentReference docRef = session.doc(widget.sessionId);
// Create a stream to listen for changes to the document with the specified ID
    StreamSubscription<DocumentSnapshot> docStream =
        docRef.snapshots().listen((docSnapshot) {
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
      String state = docSnapshot.get('State');
      if (state == 'start') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Quiz(widget.code, widget.sessionId, widget.playerId)),
        );
      }
    });
  }

  @override
  initState() {
    gotoQuiz();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 75, 235),
          title: const Text("Waiting Screen")),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SpinKitThreeInOut(
            itemBuilder: (context, index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: index.isEven
                        ? Color(0xFF7a9ee6)
                        : Color.fromARGB(255, 232, 148, 176)),
              );
            },
            size: 60.0,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text("Waiting for others players to join",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w300)),
        ]),
      ),
    );
  }
}
