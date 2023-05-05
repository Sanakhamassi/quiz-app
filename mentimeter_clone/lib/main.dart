import 'package:flutter/material.dart';

import 'package:mentimeter_clone/screens/code_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

//to secure access to firestore from my app
Future<void> signInAnonymously() async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    print('Signed in anonymously with user id: ${userCredential.user!.uid}');
  } catch (e) {
    print('Error signing in anonymously: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mentimeter Quiz',
        theme: ThemeData(
            // primarySwatch: Colors.pink,
            // backgroundColor: Colors.pink,
            // accentColor: Colors.deepPurple,
            // accentColorBrightness: Brightness.dark,
            // buttonTheme: ButtonTheme.of(context).copyWith(
            //   buttonColor: Colors.pink,
            //   textTheme: ButtonTextTheme.primary,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            // ),
            ),
        home: const CodeScreen(title: 'Code screen'));
  }
}
