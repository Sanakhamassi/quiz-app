import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentimeter_clone/models/question.dart';
import 'package:mentimeter_clone/screens/questionForm.dart';
import '../widgets/textDialog.dart';
import '../widgets/utils.dart';

class detailsScreen extends StatefulWidget {
  String code;
  detailsScreen(this.code, {super.key});

  @override
  State<detailsScreen> createState() => _detailsScreenState();
}

class _detailsScreenState extends State<detailsScreen> {
  List<Question> questions = [];
  Future editCodeQuiz(String data) async {
    final codeQuiz = await showTextDialog(
      context,
      title: 'Update ',
      value: data,
    );
  }

  Future<void> getQuestion() async {
    // reference to parent collection
    CollectionReference<Map<String, dynamic>> parentCollectionRef =
        FirebaseFirestore.instance.collection('Quiz');
// reference to quiz inside the parent collection
    DocumentReference<Map<String, dynamic>> documentRef =
        parentCollectionRef.doc(widget.code);
// reference to nested collection inside the quiz
    CollectionReference<Map<String, dynamic>> nestedCollectionRef =
        documentRef.collection('Questions');
// query the nested collection
    QuerySnapshot<Map<String, dynamic>> nestedCollectionSnapshot =
        await nestedCollectionRef.get();
    setState(() {
      questions = getQuestions(nestedCollectionSnapshot);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.code);
    getQuestion();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 75, 235),
          title: const Text("Questions details"),
        ),
        body: Column(
          children: [
            buildDataTable(),
            Center(
              child: ElevatedButton(
                child: Text('Add a Question'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddQuestion(widget.code)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(250, 40),
                  primary: Color.fromARGB(255, 26, 108, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildDataTable() {
    final columns = ['Questions', 'Answer', 'Image'];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(questions),
    );
  }

  List<DataColumn> getColumns(List<String> columns) {
    return columns.map((String column) {
      final isAge = column == columns[2];

      return DataColumn(
        label: Text(column),
      );
    }).toList();
  }

  List<DataRow> getRows(List<Question> questions) =>
      questions.map((Question question) {
        final cells = [
          question.questionText,
          question.Valid_answer,
          question.imageQuestion
        ];

        return DataRow(
          cells: Utils.modelBuilder(cells, (index, cell) {
            final showEditIcon = index == 0 || index == 1;

            return DataCell(
              Text('$cell'),
              showEditIcon: showEditIcon,
              onTap: () {
                editCodeQuiz(cell);
              },
            );
          }),
        );
      }).toList();
}
