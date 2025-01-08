import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlescore/screens/team_member_screen.dart';
import '../services/game_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import 'team_selection_screen.dart';
import 'scoreboard_screen.dart';
import 'finished_game_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameService _gameService = GameService();
  final UserService _userService = UserService();

  void _startGameSetup() async {
    String? gameName;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Game'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Game Name'),
            onChanged: (value) {
              gameName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (gameName != null && gameName!.isNotEmpty) {
                  Navigator.pop(context);
                  _createGame(gameName!);
                }
              },
              child: Text('Create Game'),
            ),
          ],
        );
      },
    );
  }

  void _createGame(String gameName) async {
    final snapshot = await _userService.getUsers().first;
    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No team members available to create a game.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamSelectionScreen(
          gameName: gameName,
          players: snapshot.docs,
          onGameCreated: () => setState(() {}),
        ),
      ),
    );
  }

  void _viewGame(String gameId, bool isOngoing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isOngoing
            ? ScoreboardScreen(gameId: gameId)
            : FinishedGameDetailsScreen(gameId: gameId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _gameService.getGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available.'));
          }

          final games = snapshot.data!.docs;
          final ongoingGames = games.where((doc) => doc['status'] == 'ongoing').toList();
          final finishedGames = games.where((doc) => doc['status'] == 'completed').toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text('Team Members'),
                    trailing: Icon(Icons.group),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamMembersScreen(),
                      ),
                    ),
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    title: Text('Ongoing Games'),
                    children: ongoingGames.map((game) {
                      return ListTile(
                        title: Text(game['name']),
                        onTap: () => _viewGame(game.id, true),
                      );
                    }).toList(),
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    title: Text('Finished Games'),
                    children: finishedGames.map((game) {
                      return ListTile(
                        title: Text(game['name']),
                        onTap: () => _viewGame(game.id, false),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startGameSetup,
        child: Icon(Icons.add),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}
