import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mentimeter_clone/models/palyer.dart';
import 'package:mentimeter_clone/models/question.dart';
import 'package:mentimeter_clone/screens/Score_Screen.dart';
import 'package:mentimeter_clone/widgets/question_widget.dart';

class Quiz extends StatefulWidget {
  String code;
  String sessionId;
  String playerId;
  Quiz(this.code, this.sessionId, this.playerId, {Key? key}) : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  late Question question;
  List<Player> players = [];
  List<dynamic> playersIds = [];
  int currentScore = 0;
  int score = 0;
  ValueNotifier<int> seconds = ValueNotifier(20);
  int maxSeconds = 20;
  late bool correct;
  bool _isNavigating = false;
  CollectionReference player = FirebaseFirestore.instance.collection('Player');
  ValueNotifier<int> playerScoreNotifier = ValueNotifier(0);
  Timer? timer;
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        timer.cancel();
        seconds.value = 20;
      }
    });
  }

//Request are async so add async
  Future<void> getScore() async {
    DocumentReference docRef = player.doc(widget.playerId);
// Create a stream to listen for changes to the document with the specified ID
    StreamSubscription<DocumentSnapshot> docStream =
        docRef.snapshots().listen((docSnapshot) {
      // Get the data from the document
      setState(() {
        //currentScore.value = docSnapshot.get('playerScore');
      });
    });
  }

  void _navigateToNextScreen(BuildContext context) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScoreScreen(widget.sessionId)),
      );
    } catch (e) {
      print('Error navigating to MyScreen: $e');
    }
  }

  late StreamSubscription<DocumentSnapshot> playerScoreSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playerScoreSubscription = FirebaseFirestore.instance
        .collection('Player')
        .doc(widget.playerId)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        currentScore = snapshot.get('playerScore');
        playerScoreNotifier.value = currentScore;
      }
    });
    question = Question('', [], '', '');
  }

  void dispose() {
    playerScoreSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 75, 235),
        title: const Text('Quiz Screen'),
        shadowColor: Colors.transparent,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: playerScoreNotifier,
            builder: (BuildContext context, int value, Widget? child) {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  'Score: $value',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('QuizSession').snapshots(),
          builder: (ctx, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (streamSnapshot.hasData) {
              //return CircularProgressIndicator();
              QueryDocumentSnapshot? document =
                  streamSnapshot.data!.docs.firstWhere(
                (doc) => doc.id == widget.sessionId,
              );
              Map<String, dynamic>? data =
                  document.data() as Map<String, dynamic>?;
              if (data!['State'] == 'finish') {
                _navigateToNextScreen(context);
              }
              startTimer();
              if (data['currentQuestion'] != null) {
                dynamic fieldValue = data['currentQuestion'];
                List<dynamic> list = fieldValue['Ansewrs'];
                List<Answer> answers = list
                    .map((answerData) => Answer.fromMap(answerData))
                    .toList();

                question = Question(fieldValue['Question'], answers,
                    fieldValue['Valid_answer'], fieldValue['imageQuestion']);
              }
              // Create a key to identify the QuestionWidget instance
              Key questionWidgetKey = UniqueKey();
              // Create the QuestionWidget instance with the key
              Question_Widget questionWidget = Question_Widget(
                key: questionWidgetKey,
                question: question,
                playerId: widget.playerId,
              );
              return Container(
                  alignment: Alignment.topCenter,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("./assets/images/bubble.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [buildTime(), questionWidget],
                  ));
            } else {
              return SpinKitThreeInOut(
                itemBuilder: (context, index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: index.isEven
                            ? Color(0xFF7a9ee6)
                            : Color.fromARGB(255, 232, 148, 176)),
                  );
                },
                size: 50.0,
              );
            }
          }),
    );
  }

  Widget buildTimer() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            //value: seconds.value / maxSeconds,
            valueColor: AlwaysStoppedAnimation(Colors.black),
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
    return ValueListenableBuilder<int>(
        valueListenable: seconds,
        builder: (BuildContext context, int second, Widget? child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Remaining time :$second',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
              Icon(
                Icons.timer,
                color: Colors.black,
                size: 40,
              )
            ],
          );
        });
  }
}
