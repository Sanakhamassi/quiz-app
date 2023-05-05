class Player {
  final String playerName;
  final int playerScore;
  final int playerRate;

  Player(
      {required this.playerName,
      required this.playerRate,
      required this.playerScore});

  factory Player.fromFirestore(Map<String, dynamic> data) {
    return Player(
      playerName: data['playerName'],
      playerRate: data['playerRank'],
      playerScore: data['playerScore'],
    );
  }
}
