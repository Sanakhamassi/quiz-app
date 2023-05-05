import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentimeter_clone/screens/questions_details.dart';

import '../widgets/flash_message_widget.dart';

class AddQuestion extends StatefulWidget {
  String code;

  AddQuestion(this.code, {Key? key}) : super(key: key);

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  TextEditingController questionText = TextEditingController();
  TextEditingController imageUrl = TextEditingController();

//Answer dybamex TextInput
  TextEditingController firstAnswer = TextEditingController();
  TextEditingController secondAnswer = TextEditingController();
  TextEditingController thirdAnswer = TextEditingController();
  TextEditingController fourdhAnswer = TextEditingController();
  TextEditingController fidthAnswer = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List allTextField = [];
  List Answers = [];
  Future<void> addQuestion() async {
    final quizRef =
        FirebaseFirestore.instance.collection('Quiz').doc(widget.code);
    final questioRef = quizRef.collection('Questions');
    final newQuestion = await questioRef.add({
      'Question': questionText.text,
      'Valid_answer': Answers.first,
      'imageQuestion': imageUrl.text,
      'Answers': Answers
    });
    final newQueId = newQuestion.id;

    //final newQuestionSnapshot = await newQuestion.get();
    if (newQueId != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: FlashMessageWidget(
            "New Question was created successfull", Colors.green),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            FlashMessageWidget("Failed to add new Question", Colors.redAccent),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allTextField = [
      {
        "label": "First Answer",
        "keyforbackend": "first_answer",
        "value": firstAnswer,
        "text_field": TextFormField(
          controller: firstAnswer,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required ';
            }
            return null;
          },
        ),
      },
      {
        "label": "Second Answer",
        "keyforbackend": "second_answer",
        "value": secondAnswer,
        "text_field": TextFormField(
          controller: secondAnswer,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required ';
            }
            return null;
          },
        ),
      },
      {
        "label": "Third Answer",
        "keyforbackend": "third_answer",
        "value": thirdAnswer,
        "text_field": TextFormField(
          controller: thirdAnswer,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      },
      {
        "label": "Fourth Answer",
        "keyforbackend": "fourdh_answer",
        "value": fourdhAnswer,
        "text_field": TextFormField(
          controller: fourdhAnswer,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required ';
            }
            return null;
          },
        ),
      },
      {
        "label": "Fidth Answer",
        "keyforbackend": "last_answer",
        "value": fidthAnswer,
        "text_field": TextFormField(
          controller: fidthAnswer,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      }
    ];
  }

  List displayTextField = [];

  addTextField() {
    print("addTextField");
    setState(() {
      if (allTextField.length == displayTextField.length) {
        print("Nafsou");
        return;
      } else {
        displayTextField.add(allTextField[displayTextField.length]);
      }
    });
  }

  removeTextField() {
    print("removeTextField");

    setState(() {
      if (displayTextField.isNotEmpty) {
        displayTextField.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 75, 235),
        centerTitle: true,
        title: const Text("Add Question"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: questionText,
                    decoration: const InputDecoration(
                      label: Text("Enter Question Text"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required text  ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: imageUrl,
                    decoration: const InputDecoration(
                      label: Text("Copy Image url"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required text  ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text('The valid answer is the first text field'),
                  ...displayTextField
                      .map(
                        (e) => Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, right: 20),
                              child: Text(
                                e['label'],
                              ),
                            ),
                            Expanded(child: e['text_field'])
                          ],
                        ),
                      )
                      .toList(),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Answer:'),
                      ElevatedButton(
                          onPressed: addTextField,
                          child: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 252, 68, 60),
                          )),
                      ElevatedButton(
                          onPressed: removeTextField,
                          child: const Text('Remove'),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 252, 68, 60),
                          )),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          List finalDynamicTextFieldValue = [];

                          if (displayTextField.isNotEmpty) {
                            for (int i = 0; i < displayTextField.length; i++) {
                              TextEditingController answerValue =
                                  displayTextField[i]['value'];

                              Map dummyMap = {
                                "${displayTextField[i]['keyforbackend']}":
                                    answerValue.text
                              };
                              setState(() {
                                Answers.add(answerValue.text);
                              });
                              print(Answers);
                              print(dummyMap);
                              finalDynamicTextFieldValue.add(dummyMap);
                            }
                          }

                          Map requiredFormDataForBackend = {
                            'questionText': questionText.text,
                            "Answers": finalDynamicTextFieldValue
                          };
                          print("Final Data $requiredFormDataForBackend");
                        }
                        addQuestion();
                      },
                      child: const Text("Submit Data"),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(200, 30),
                        primary: Color.fromARGB(255, 252, 68, 60),
                      ))
                ],
              )),
        ),
      ),
    );
  }
}
