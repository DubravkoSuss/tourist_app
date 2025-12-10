import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Box _usersBox;
  String _currentUserEmail = '';
  List<Map<String, dynamic>> _otherUsers = [];

  @override
  void initState() {
    super.initState();
    _usersBox = Hive.box('users');
    _loadUsers();
  }

  void _loadUsers() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserEmail = authState.user.email;

      // Get all users except current user
      final allUsers = _usersBox.keys.where((key) => key != _currentUserEmail);

      setState(() {
        _otherUsers = allUsers.map((email) {
          final userData = _usersBox.get(email);
          return {
            'email': email.toString(),
            'name': userData['name'] ?? 'User',
            'avatar_path': userData['avatar_path'],
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: _otherUsers.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No other users yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create another account to test messaging',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _otherUsers.length,
        itemBuilder: (context, index) {
          final user = _otherUsers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(
                user['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                user['email'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              trailing: const Icon(Icons.chat_bubble_outline),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      otherUserEmail: user['email'],
                      otherUserName: user['name'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}