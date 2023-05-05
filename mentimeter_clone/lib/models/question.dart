import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String questionText;
  List<Answer> answersList;
  String Valid_answer;
  String imageQuestion;

  Question(this.questionText, this.answersList, this.Valid_answer,
      this.imageQuestion);
}

class Answer {
  final String answerText;
  final bool isCorrect;

  Answer({required this.answerText, required this.isCorrect});

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      answerText: map['text'] as String,
      isCorrect: map['isCorrect'] as bool,
    );
  }
}
