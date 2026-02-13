import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_theme.dart';
import '../providers/user_provider.dart';
import '../models/group_model.dart';

class GroupMembersScreen extends ConsumerWidget {
  final Group group;

  const GroupMembersScreen({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersListAsync = ref.watch(usersListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        title: Text('${group.name} Members'),
      ),
      body: usersListAsync.when(
        data: (allUsers) {
          // Filter users to only show group members
          final memberUsers = allUsers.where((user) => 
            group.members.contains(user.id)
          ).toList();

          return ListView.builder(
            itemCount: memberUsers.length,
            itemBuilder: (context, index) {
              final member = memberUsers[index];
              final isAdmin = member.id == group.adminId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    member.username[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  member.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: isAdmin
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading members: $error'),
        ),
      ),
    );
  }
}
