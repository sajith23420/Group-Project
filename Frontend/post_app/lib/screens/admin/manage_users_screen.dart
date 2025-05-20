import 'package:flutter/material.dart';

// Mock user data model
class User {
  final String name;
  final String email;
  final String role;

  const User({required this.name, required this.email, required this.role});
}

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  // Mock list of users
  final List<User> users = const [
    User(name: "Alice Smith", email: "alice@example.com", role: "User"),
    User(name: "Bob Johnson", email: "bob@example.com", role: "Moderator"),
    User(name: "Charlie Lee", email: "charlie@example.com", role: "User"),
    User(name: "Diana Prince", email: "diana@example.com", role: "Admin"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Registered Users',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.pinkAccent,
                        child: Text(user.name[0],
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: Chip(
                        label: Text(user.role),
                        backgroundColor: user.role == "Admin"
                            ? Colors.yellow
                            : Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: user.role == "Admin"
                              ? Colors.black
                              : Colors.pinkAccent,
                        ),
                      ),
                      // Optionally, add actions like delete, promote, etc.
                      // onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
