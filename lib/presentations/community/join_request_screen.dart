import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/repositories/community_repository.dart';
import '../../app/repositories/user_repository.dart';
import '../../app/models/app_user.dart';

class JoinRequestsScreen extends StatelessWidget {
  final String communityId;
  const JoinRequestsScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final repo = CommunityRepository();
    final userRepo = UserRepository();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Join Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: repo.firestore.collection('communities').doc(communityId).collection('joinRequests').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No requests'));
          
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final uid = data['userId'] as String;
              
              return FutureBuilder<AppUser?>(
                future: userRepo.getUser(uid),
                builder: (context, userSnap) {
                  final user = userSnap.data;
                  final displayName = user?.displayName!.isNotEmpty == true
                      ? user!.displayName 
                      : (user?.email ?? uid);
                  
                  return ListTile(
                    title: Text(displayName!),
                    subtitle: Text(user?.email ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => repo.approveJoin(communityId, uid), 
                          child: const Text('Approve')
                        ),
                        TextButton(
                          onPressed: () => repo.rejectJoin(communityId, uid), 
                          child: const Text('Reject')
                        ),
                      ],
                    ),
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
