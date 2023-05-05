import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mentimeter_clone/widgets/answerBox.dart';

import '../models/question.dart';

class Question_Widget extends StatefulWidget {
  Question question;
  String playerId;

  Question_Widget({
    Key? key,
    required this.question,
    required this.playerId,
  }) : super(key: key);

  @override
  State<Question_Widget> createState() => _Question_WidgetState();
}

class _Question_WidgetState extends State<Question_Widget> {
  late int _nbAnswer;
  bool isSelected = false;
  late int playerScore;
  bool _isButtonEnabled = false;
  int score = 0;
  late DocumentReference docRef;
  CollectionReference player = FirebaseFirestore.instance.collection('Player');
  void getScore() {
    FirebaseFirestore.instance
        .collection('Player')
        .doc(widget.playerId)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          playerScore = snapshot['playerScore'];
        });
      }
    });
  }

  @override
  void initState() {
    docRef = player.doc(widget.playerId);

    getScore();
    // TODO: implement initState
    super.initState();
  }

  Future<void> setScore1() async {
    await docRef.update({'playerScore': FieldValue.increment(20)});
  }

  void setScore() {
    try {
      if (widget.playerId != null) {
        FirebaseFirestore.instance
            .collection('Player')
            .doc(widget.playerId)
            .get()
            .then((DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            FirebaseFirestore.instance
                .collection('Player')
                .doc(widget.playerId)
                .update({'playerScore': score}).then((value) {
              print('Document updated successfully!');
            }).catchError((error) => print('Error updating document: $error'));
          } else {
            print('Player does not exist');
          }
        }).catchError((error) => print('Error getting user: $error'));
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void calculScore(bool isCorrect) {
    if (_isButtonEnabled) {
      return;
    } else {
      if (isCorrect == true) {
        setScore1();
      }
      setState(() {
        isSelected = true;
        
        _isButtonEnabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            shadowColor: Color(0xFFFFC107),
            color: Colors.white,
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                Stack(alignment: Alignment.center, children: [
                  Ink.image(
                    image: NetworkImage(widget.question.imageQuestion),
                    child: InkWell(
                      onTap: () {},
                    ),
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.question.questionText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 25),
                      ),
                    ],
                  ),
                ]),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    for (Answer answer in widget.question.answersList)
                      GestureDetector(
                        onTap: () => calculScore(answer.isCorrect),
                        child: AnswerBox(
                          answer.answerText,
                          isSelected
                              ? answer.isCorrect == true
                                  ? Colors.green
                                  : Colors.red
                              : Colors.blue,
                          isSelected
                              ? answer.isCorrect == true
                                  ? Icon(Icons.check, color: Colors.white)
                                  : Icon(Icons.close, color: Colors.white)
                              : Icon(Icons.quickreply, color: Colors.white),
                        ),
                      ),
                  ]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
