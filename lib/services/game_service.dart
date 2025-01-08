import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of games
  Stream<QuerySnapshot> getGames() {
    return _firestore.collection('games').snapshots();
  }

  // Fetch a specific game
  Future<DocumentSnapshot> getGame(String gameId) {
    return _firestore.collection('games').doc(gameId).get();
  }

  // Create a new game
  Future<void> createGame({
    required List<Map<String, dynamic>> team1,
    required List<Map<String, dynamic>> team2,
    required DateTime startTime,
    required String name,
  }) async {
    await _firestore.collection('games').add({
      'name': name,
      'team1': team1,
      'team2': team2,
      'team1Score': 0,
      'team2Score': 0,
      'status': 'ongoing',
      'startTime': startTime,
    });
  }

  // Update player's points
  Future<void> updatePlayerPoints(String gameId, String team, String playerId, int change) async {
    final gameRef = _firestore.collection('games').doc(gameId);
    final gameData = await gameRef.get();
    final data = gameData.data() as Map<String, dynamic>;

    // Find and update the player's points
    List<dynamic> players = List.from(data[team]);
    for (var player in players) {
      if (player['id'] == playerId) {
        player['points'] = (player['points'] ?? 0) + change;
        break;
      }
    }

    // Update the team's player list in Firestore
    await gameRef.update({
      team: players,
    });
  }

  // Update player's fouls
  Future<void> updatePlayerFouls(String gameId, String team, String playerId) async {
    final gameRef = _firestore.collection('games').doc(gameId);
    final gameData = await gameRef.get();
    final data = gameData.data() as Map<String, dynamic>;

    // Find and update the player's fouls
    List<dynamic> players = List.from(data[team]);
    for (var player in players) {
      if (player['id'] == playerId) {
        player['fouls'] = (player['fouls'] ?? 0) + 1;
        break;
      }
    }

    // Update the team's player list in Firestore
    await gameRef.update({
      team: players,
    });
  }

  // Update the team's total score
  Future<void> updateGameScore(String gameId, String teamKey, int change) async {
    final gameRef = _firestore.collection('games').doc(gameId);
    await gameRef.update({
      teamKey: FieldValue.increment(change),
    });
  }

  // End the game
  Future<void> endGame(String gameId) async {
    final gameRef = _firestore.collection('games').doc(gameId);
    final gameData = await gameRef.get();
    final data = gameData.data() as Map<String, dynamic>;

    // Determine the winner
    final winner = data['team1Score'] > data['team2Score']
        ? 'Team 1'
        : data['team2Score'] > data['team1Score']
        ? 'Team 2'
        : 'Draw';

    await gameRef.update({
      'status': 'completed',
      'winner': winner,
    });
  }
}
