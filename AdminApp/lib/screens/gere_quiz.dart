import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mentimeter_clone/screens/questions_details.dart';
import 'package:mentimeter_clone/widgets/textDialog.dart';

import '../models/question.dart';
import '../widgets/flash_message_widget.dart';

class manageQuiz extends StatefulWidget {
  const manageQuiz({super.key});

  @override
  State<manageQuiz> createState() => _manageQuizState();
}

class _manageQuizState extends State<manageQuiz> {
  List<Question> questions = [];
  List<dynamic> QuizId = [];
  TextEditingController controllerCode = TextEditingController();
  dynamic code = '';
  final CollectionReference quiz =
      FirebaseFirestore.instance.collection('Quiz');

  Future<void> getQuestion(String code) async {
    // reference to parent collection
    CollectionReference<Map<String, dynamic>> parentCollectionRef =
        FirebaseFirestore.instance.collection('Quiz');
// reference to quiz inside the parent collection
    DocumentReference<Map<String, dynamic>> documentRef =
        parentCollectionRef.doc(code);
// reference to nested collection inside the quiz
    CollectionReference<Map<String, dynamic>> nestedCollectionRef =
        documentRef.collection('Questions');
// query the nested collection
    QuerySnapshot<Map<String, dynamic>> nestedCollectionSnapshot =
        await nestedCollectionRef.get();
    setState(() {
      questions = getQuestions(nestedCollectionSnapshot);
      print(questions);
    });
  }

  Future<void> startQuiz() async {
    FirebaseFirestore.instance.collection('Quiz').get().then((querySnapshot) {
      int nombreDeDocuments = querySnapshot.size;
      print('Nombre de quiz: $nombreDeDocuments');
    }).catchError((error) =>
        print('Erreur lors de la récupération des documents: $error'));

// reference to parent collection
    CollectionReference<Map<String, dynamic>> parentCollectionRef =
        FirebaseFirestore.instance.collection('Quiz');
  }

  void deleteQuiz(String code) {
    DocumentReference quizRef =
        FirebaseFirestore.instance.collection('Quiz').doc(code);

    quizRef
        .delete()
        .then((value) => {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: FlashMessageWidget(
                    "Quiz deleted successufully", Colors.green),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ))
            })
        .catchError((error) => {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    FlashMessageWidget("Failed to delete quiz", Colors.red),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ))
            });
    refresh();
  }

  void addQuizCode() {
    code = controllerCode.text;
    quiz
        .doc(code)
        .set(<String, dynamic>{})
        .then((value) => print('Quiz added'))
        .catchError((error) => print('Failed to add quiz: $error'));
    refresh();
    Navigator.of(context).pop();
  }

  void refresh() {
    QuizId = [];
    FirebaseFirestore.instance.collection('Quiz').get().then((value) {
      value.docs.forEach((element) async {
        setState(() {
          QuizId.add(element.id);
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 75, 235),
          title: const Text("Manage Quiz"),
        ),
        body: SizedBox(
            height: 500, // Replace with desired height
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: QuizId.length,
                      itemBuilder: (context, index) {
                        final code = QuizId[index];
                        return Slidable(
                            startActionPane:
                                ActionPane(motion: StretchMotion(), children: [
                              SlidableAction(
                                label: 'Update',
                                backgroundColor: Colors.green,
                                icon: Icons.update,
                                onPressed: (context) => {editCodeQuiz(code)},
                              ),
                              SlidableAction(
                                label: 'Details',
                                backgroundColor: Colors.blue,
                                icon: Icons.details,
                                onPressed: (context) => {
                                  getQuestion(code),
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            detailsScreen(code)),
                                  )
                                },
                              )
                            ]),
                            endActionPane:
                                ActionPane(motion: StretchMotion(), children: [
                              SlidableAction(
                                label: 'Delete',
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (context) => {deleteQuiz(code)},
                              )
                            ]),
                            child: _buildListTile(code));
                      }),
                ),
                ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_box, color: Colors.white, size: 25),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Add a Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    showText(context);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(250, 40),
                    primary: Color.fromARGB(255, 26, 108, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            )));
  }

  Future editCodeQuiz(String quizCode) async {
    final codeQuiz = await showTextDialog(
      context,
      title: 'Change code Quiz',
      value: quizCode,
    );
  }

  Future<T?> showText<T>(BuildContext context) => showDialog<T>(
        context: context,
        builder: (context) => _addQuiz(),
      );

  Widget _addQuiz() {
    return (AlertDialog(
      title: Text("Tap Quiz Code"),
      content: TextField(
        controller: controllerCode,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(220, 40),
              primary: Color.fromARGB(255, 26, 108, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Center(child: Text('Add')),
            onPressed: () => {addQuizCode()},
          ),
        )
      ],
    ));
  }

  Widget _buildListTile(String code) {
    return Card(
      // color: Color.fromARGB(162, 231, 197, 223),
      elevation: 5,
      child: ListTile(
        title: Text(
          'Quiz code : $code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.add_box),
        //trailing: Icon(Icons.arrow_forward),
      ),
    );
  }
}
