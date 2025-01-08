import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('team_members');

  // Add a new user
  Future<void> addUser({
    required String name,
    required int age,
    required String position,
    required String addedBy,
  }) async {
    await _usersCollection.add({
      'name': name,
      'age': age,
      'position': position,
      'addedBy': addedBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Fetch all users
  Stream<QuerySnapshot> getUsers() {
    return _usersCollection.snapshots();
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).delete();
  }
}
