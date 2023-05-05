import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../widgets/flash_message_widget.dart';

class StartQuiz extends StatefulWidget {
  String code;
  String sessionId;
  StartQuiz(this.code, this.sessionId, {Key? key}) : super(key: key);
  @override
  State<StartQuiz> createState() => _StartQuizState();
}

class _StartQuizState extends State<StartQuiz> {
  int nbPlayer = 0;
  int nbMax = 0;
  int _currentIndex = 1;
  int maxSeconds = 20;
  int seconds = 20;
  Timer? timer;
  String buttonLabel = "Next Question";
  String state = "";
  CollectionReference session =
      FirebaseFirestore.instance.collection('QuizSession');
  List<Question> _questions = [];
  bool isButtonVisible = true;
  late Question currentQuestion;
  void exitApp() {
    session.doc(widget.sessionId).delete();
    SystemNavigator.pop(); // Close the app
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          seconds = 20;
        });
      }
    });
  }

  Future<void> createSession() async {
    DocumentReference docRef = session.doc(widget.sessionId);
    StreamSubscription<DocumentSnapshot> docStream =
        docRef.snapshots().listen((docSnapshot) {
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('Players')) {
        List<dynamic> players = docSnapshot.get('Players');
        setState(() {
          nbPlayer = players != null ? players.length : 0;
          nbMax = docSnapshot.get('nbMax');
        });
      }
    });
    if (nbPlayer == nbMax) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: FlashMessageWidget(
            "Nombre maximale de players atteint", Colors.green),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
    }
  }

  Future<void> startQuiz() async {
    if (nbMax != 0) {
      DocumentReference docRef = session.doc(widget.sessionId);
      await docRef.update({
        'State': 'start',
      });
// reference to parent collection quiz
      CollectionReference<Map<String, dynamic>> parentCollectionRef =
          FirebaseFirestore.instance.collection('Quiz');
// reference to quiz inside the parent collection
      DocumentReference<Map<String, dynamic>> documentRef =
          parentCollectionRef.doc(widget.code);
// reference to nested collection inside the quiz (Questions)
      CollectionReference<Map<String, dynamic>> nestedCollectionRef =
          documentRef.collection('Questions');
// query the nested collection
      QuerySnapshot<Map<String, dynamic>> nestedCollectionSnapshot =
          await nestedCollectionRef.get();
      setState(() {
        _questions = getQuestions(nestedCollectionSnapshot);
      });
      Map<String, dynamic> currentQuestion = {
        'Question': _questions.first.questionText,
        'Valid_answer': _questions.first.Valid_answer,
        'imageQuestion': _questions.first.imageQuestion,
        'Ansewrs': _questions.first.answersList.map((answer) => answer.toMap()),
      };
      await docRef.update({'currentQuestion': currentQuestion});
      startTimer();
      setState(() {
        isButtonVisible = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            FlashMessageWidget("Numbers of Player is zero", Colors.redAccent),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
    }
  }

  Future<void> nextQuesion() async {
    DocumentReference docRef = session.doc(widget.sessionId);
    docRef.get().then((doc) {
      if (doc.exists) {
        setState(() {
          state = doc.get('State');
        });
      } else {
        print('Document does not exist');
      }
    });

    if (_currentIndex >= _questions.length) {
      setState(() {
        buttonLabel = 'Show Score';
      });
      await docRef.update({'State': 'finish'});
    } else if (state == 'start') {
      Map<String, dynamic> currentQuestion = {
        'Question': _questions[_currentIndex].questionText,
        'Valid_answer': _questions[_currentIndex].Valid_answer,
        'imageQuestion': _questions[_currentIndex].imageQuestion,
        'Ansewrs': _questions[_currentIndex]
            .answersList
            .map((answer) => answer.toMap())
      };
      await docRef.update({'currentQuestion': currentQuestion});
      startTimer();
      setState(() {
        _currentIndex++;
      });
    }
  }

  void showScore() {}
  @override
  void initState() {
    createSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isRunning = timer == null ? false : timer!.isActive;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 75, 235),
          title: const Text("Monitor Quiz"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                exitApp();
                // add code to perform exit action
              },
            )
          ]),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("./assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
            child: SizedBox(
          child: Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildTimer(),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Number of Players',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 115, 155, 235),
                            ),
                            child: Center(
                              child: Text(
                                nbPlayer.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      isButtonVisible
                          ? ElevatedButton(
                              onPressed: () => startQuiz(),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(250, 50),
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
                                  )),
                              child: const Text("Start quiz"))
                          : ElevatedButton(
                              onPressed: () => nextQuesion(),
                              child: Text(buttonLabel),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(250, 50),
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
                                  ))),
                    ],
                  ),
                ),
              )),
        )),
      ),
    );
  }

  Widget buildTimer() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: seconds / maxSeconds,
            valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
            backgroundColor: Colors.greenAccent,
            strokeWidth: 10,
          ),
          Center(
            child: buildTime(),
          )
        ],
      ),
    );
  }

  Widget buildTime() {
    return Text(
      '$seconds',
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.lightGreen, fontSize: 30),
    );
  }
}
