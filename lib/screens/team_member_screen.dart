import 'package:flutter/material.dart';
import '../services/user_service.dart';

class TeamMembersScreen extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Team Members')),
      body: StreamBuilder(
        stream: _userService.getUsers(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
            return Center(child: Text('No team members found.'));
          }

          final members = snapshot.data.docs;
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                title: Text(member['name']),
                subtitle: Text(member['age'].toString()),
              );
            },
          );
        },
      ),
    );
  }
}
