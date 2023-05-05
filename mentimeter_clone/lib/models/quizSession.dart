import 'package:mentimeter_clone/models/palyer.dart';

class quizSession {
  final int nbMax;
  final List<Player> players;
  final String State;

  quizSession(
    this.nbMax,
    this.State,
    this.players,
  );
}
