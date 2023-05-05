import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String questionText;
  final List<Answer> answersList;
  final String Valid_answer;
  final String imageQuestion;

  Question(this.questionText, this.answersList, this.Valid_answer,
      this.imageQuestion);
}

class Answer {
  final String answerText;
  final bool isCorrect;

  Answer(this.answerText, this.isCorrect);
  // convert the custom object to a map
  Map<String, dynamic> toMap() {
    return {
      'text': answerText,
      'isCorrect': isCorrect,
    };
  }
}

List<Question> getQuestions(nestedCollectionSnapshot) {
  List<Question> questions = [];
  List<Answer> answers = [];
  nestedCollectionSnapshot.docs.forEach((doc) {
    Map<String, dynamic> docData = doc.data();
    for (String answer in docData['Answers']) {
      if (answer == docData['Valid_answer']) {
        answers.add(Answer(answer, true));
      } else {
        answers.add(Answer(answer, false));
      }
    }
    questions.add(Question(docData['Question'], answers,
        docData['Valid_answer'], docData['imageQuestion']));
    answers = [];
  });

  return questions;
}
