import 'package:flutter/material.dart';
import '../services/game_service.dart';

class FinishedGameDetailsScreen extends StatelessWidget {
  final String gameId;

  FinishedGameDetailsScreen({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final GameService _gameService = GameService();

    return Scaffold(
      appBar: AppBar(title: Text('Game Details')),
      body: FutureBuilder(
        future: _gameService.getGame(gameId),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available.'));
          }

          final gameData = snapshot.data.data() as Map<String, dynamic>;
          return ListView(
            children: [
              ListTile(
                title: Text('Game Name'),
                subtitle: Text(gameData['name']),
              ),
              ListTile(
                title: Text('Team 1 Score'),
                subtitle: Text('${gameData['team1Score']}'),
              ),
              ListTile(
                title: Text('Team 2 Score'),
                subtitle: Text('${gameData['team2Score']}'),
              ),
              ListTile(
                title: Text('Winner'),
                subtitle: Text(gameData['winner'] ?? 'Not determined'),
              ),
            ],
          );
        },
      ),
    );
  }
}
