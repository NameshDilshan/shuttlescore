import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../theme/app_colors.dart';

class TeamSelectionScreen extends StatefulWidget {
  final String gameName;
  final List<QueryDocumentSnapshot> players;
  final VoidCallback onGameCreated;

  TeamSelectionScreen({
    required this.gameName,
    required this.players,
    required this.onGameCreated,
  });

  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  List<Map<String, dynamic>> team1 = [];
  List<Map<String, dynamic>> team2 = [];
  List<Map<String, dynamic>> availablePlayers = [];

  @override
  void initState() {
    super.initState();
    availablePlayers = widget.players
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  void _saveGame() async {
    if (team1.isEmpty || team2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Both teams must have players!')),
      );
      return;
    }

    await GameService().createGame(
      team1: team1,
      team2: team2,
      startTime: DateTime.now(),
      name: widget.gameName,
    );

    widget.onGameCreated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Selection'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildTeamColumn('Team 1', team1, AppColors.primary),
                _buildTeamColumn('Team 2', team2, AppColors.secondary),
              ],
            ),
          ),
          _buildAvailablePlayersColumn(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Start Game'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(String title, List<Map<String, dynamic>> team, Color teamColor) {
    return Expanded(
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          // Add any validation logic here
          return true;
        },
        onAcceptWithDetails: (details) {
          final data = details.data;
          setState(() {
            if (team == team1) {
              team1.add(data);
            } else {
              team2.add(data);
            }
            availablePlayers.remove(data);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: teamColor, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: candidateData.isNotEmpty
                  ? teamColor.withAlpha(1)
                  : Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: teamColor.withAlpha(2),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: teamColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: team.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 8),
                        child: Draggable<Map<String, dynamic>>(
                          data: team[index],
                          feedback: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                team[index]['name'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: ListTile(title: Text(team[index]['name'])),
                          ),
                          child: ListTile(
                            title: Text(team[index]['name']),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle, color: AppColors.accent),
                              onPressed: () {
                                setState(() {
                                  availablePlayers.add(team[index]);
                                  team.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailablePlayersColumn() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Available Players',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final player = availablePlayers[index];
                return Draggable<Map<String, dynamic>>(
                  data: player,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 120,
                      height: 120,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 32),
                          SizedBox(height: 8),
                          Text(
                            player['name'],
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildPlayerCard(player),
                  ),
                  child: _buildPlayerCard(player),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return Card(
      margin: EdgeInsets.only(right: 8),
      child: Container(
        width: 120,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person),
            SizedBox(height: 8),
            Text(
              player['name'],
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}