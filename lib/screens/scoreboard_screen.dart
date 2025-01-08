import 'package:flutter/material.dart';
import '../services/game_service.dart';

class ScoreboardScreen extends StatefulWidget {
  final String gameId;

  ScoreboardScreen({required this.gameId});

  @override
  ScoreboardScreenState createState() => ScoreboardScreenState();
}

class ScoreboardScreenState extends State<ScoreboardScreen> {
  final GameService gameService = GameService();
  late Map<String, dynamic> gameData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGameData();
  }

  // Load game data from the database
  Future<void> loadGameData() async {
    final data = await gameService.getGame(widget.gameId);
    setState(() {
      gameData = data.data() as Map<String, dynamic>;
      isLoading = false;
    });
  }

  // Update player's points and the team's score
  void updatePlayerPoints(String team, String playerId, int change) {
    setState(() {
      // Update player points
      gameData[team].forEach((player) {
        if (player['id'] == playerId) {
          player['points'] = (player['points'] ?? 0) + change;
          // Update the team total score
          gameData[team + 'Score'] = calculateTeamScore(team);
        }
      });
    });

    // Update in database
    gameService.updatePlayerPoints(widget.gameId, team, playerId, change);
  }

  // Update fouls for a player, and increment opposing team's score
  void updatePlayerFouls(String team, String playerId) {
    setState(() {
      // Update player fouls
      gameData[team].forEach((player) {
        if (player['id'] == playerId) {
          player['fouls'] = (player['fouls'] ?? 0) + 1;

          // Determine the opposing team
          final opposingTeam = team == 'team1' ? 'team2Score' : 'team1Score';

          // Increment opposing team's score
          gameData[opposingTeam] = (gameData[opposingTeam] ?? 0) + 1;
        }
      });
    });

    // Update fouls and opposing team score in the database
    gameService.updatePlayerFouls(widget.gameId, team, playerId);
    gameService.updateGameScore(widget.gameId, team == 'team1' ? 'team2Score' : 'team1Score', 1);
  }

  // Calculate the total score for a team by summing up player points
  int calculateTeamScore(String team) {
    int totalScore = 0;
    for (var player in gameData[team]) {
      int points = player['points']?.toInt() ?? 0;
      totalScore += points;
    }
    return totalScore;
  }

  // End the game and close the screen
  void endGame() async {
    await gameService.endGame(widget.gameId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Scoreboard')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Scoreboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: endGame,
          ),
        ],
      ),
      body: Column(
        children: [
          buildTeamScoreCard('Team 1', 'team1Score'),
          buildPlayerList('team1'),
          buildTeamScoreCard('Team 2', 'team2Score'),
          buildPlayerList('team2'),
        ],
      ),
    );
  }

  // Build a score card to display the team total score
  Widget buildTeamScoreCard(String teamName, String scoreKey) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            teamName,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Total Points: ${gameData[scoreKey]}',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  // Build a list of players for each team
  Widget buildPlayerList(String team) {
    return Expanded(
      child: ListView.builder(
        itemCount: gameData[team].length,
        itemBuilder: (context, index) {
          var player = gameData[team][index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(player['name']),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Points: ${player['points']}'),
                  Text('Fouls: ${player['fouls']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => updatePlayerPoints(team, player['id'], 1),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => updatePlayerPoints(team, player['id'], -1),
                  ),
                  IconButton(
                    icon: Icon(Icons.warning),
                    onPressed: () => updatePlayerFouls(team, player['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
