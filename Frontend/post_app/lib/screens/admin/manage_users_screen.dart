import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:post_app/models/user_model.dart';
import 'package:post_app/models/enums.dart';
import 'package:post_app/services/api_client.dart';
import 'package:post_app/services/token_provider.dart';
import 'package:post_app/services/user_auth_api_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late final UserAuthApiService _userAuthApiService;
  late final ApiClient _apiClient;
  late final TokenProvider _tokenProvider;
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _tokenProvider = TokenProvider(FirebaseAuth.instance);
    _apiClient = ApiClient(_tokenProvider);
    _userAuthApiService = UserAuthApiService(_apiClient);
    _usersFuture = _userAuthApiService.adminGetAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Manage Users', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.lightBlue[100], // Light blue theme
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 2,
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
                child: FutureBuilder<List<UserModel>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: \\${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    final users = snapshot.data!;
                    return ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pinkAccent,
                            child: Text(
                              (user.displayName?.isNotEmpty == true
                                      ? user.displayName![0]
                                      : user.email?.isNotEmpty == true
                                          ? user.email![0]
                                          : '?')
                                  .toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title:
                              Text(user.displayName ?? user.email ?? 'No Name'),
                          subtitle: Text(user.email ?? 'No Email'),
                          trailing: Chip(
                            label: Text(user.role.name),
                            backgroundColor: user.role == UserRole.admin
                                ? Colors.yellow
                                : Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: user.role == UserRole.admin
                                  ? Colors.black
                                  : Colors.pinkAccent,
                            ),
                          ),
                        );
                      },
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
