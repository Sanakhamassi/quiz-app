import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/palyer.dart';

class ScoreScreen extends StatefulWidget {
  String sessionId;
  ScoreScreen(this.sessionId, {Key? key}) : super(key: key);
  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  List<Player> players = [];
  List<dynamic> playersIds = [];
  CollectionReference player = FirebaseFirestore.instance.collection('Player');
  CollectionReference session =
      FirebaseFirestore.instance.collection('QuizSession');
  checkPlayers() async {
    DocumentReference docRef = session.doc(widget.sessionId);
    await docRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          playersIds = documentSnapshot.get('Players');
        });
      }
    });
    print(playersIds);
    for (String id in playersIds) {
      DocumentSnapshot snapshot = await player.doc(id).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        Player player = Player.fromFirestore(data);
        setState(() {
          players.add(player);
          players.sort((a, b) => b.playerScore.compareTo(a.playerScore));
        });
      }
    }
    print(players);
  }

  @override
  void initState() {
    // TODO: implement initState
    checkPlayers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Score screen"),
            backgroundColor: const Color.fromARGB(255, 15, 75, 235),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  SystemNavigator.pop();
                },
              )
            ]),
        body: Stack(children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              "./assets/images/score.png",
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomLeft,
            ),
          ),
          ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return Card(
                child: ListTile(
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 115, 155, 235),
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Text(player.playerName,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      CircularPercentIndicator(
                        animation: true,
                        animationDuration: 10000,
                        radius: 30,
                        lineWidth: 10,
                        percent: player.playerScore / 100,
                        progressColor: Colors.blue,
                        backgroundColor: Colors.blue.shade200,
                        circularStrokeCap: CircularStrokeCap.round,
                        center: Text(player.playerScore.toString() + "%"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ]));
  }
}
