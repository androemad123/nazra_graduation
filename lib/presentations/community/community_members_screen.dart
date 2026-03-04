import 'package:flutter/material.dart';
import '../../app/repositories/community_repository.dart';
import '../../app/repositories/user_repository.dart';
import '../../app/models/community.dart';
import '../../app/models/app_user.dart';

class CommunityMembersScreen extends StatelessWidget {
  final String communityId;
  const CommunityMembersScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final communityRepo = CommunityRepository();
    final userRepo = UserRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: StreamBuilder<Community?>(
        stream: communityRepo.watchCommunity(communityId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final community = snap.data!;
          final memberIds = community.members;

          if (memberIds.isEmpty) {
            return const Center(child: Text('No members'));
          }

          return FutureBuilder<List<AppUser>>(
            future: userRepo.getUsers(memberIds),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final users = userSnap.data ?? [];
              
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, i) {
                  final user = users[i];
                  final displayName = user.displayName!.isNotEmpty
                      ? user.displayName 
                      : user.email;
                  final isOwner = user.uid == community.ownerId;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(displayName!.isNotEmpty ? displayName[0].toUpperCase() : '?'),
                    ),
                    title: Text(displayName),
                    subtitle: Text(user.email),
                    trailing: isOwner 
                        ? const Chip(label: Text('Owner'), backgroundColor: Colors.amber)
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
