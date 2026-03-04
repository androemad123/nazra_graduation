import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../../app/bloc/community/community_bloc.dart';
import '../../app/bloc/community/community_event.dart';
import '../../app/bloc/community/community_state.dart';
import '../../app/models/community.dart';
import '../../app/repositories/auth_repository.dart';
import '../../app/repositories/community_repository.dart';
import '../../generated/l10n.dart';
import '../resources/styles_manager.dart';
import '../widgets/app_text_btn.dart';
import 'widgets/community_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityBloc(repo: CommunityRepository()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                S.of(context).communities,
                style: semiBoldStyle(fontSize: 22, color: Colors.black87),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<CommunityBloc, CommunityState>(
                builder: (context, state) {
                  if (state.status == CommunityStatus.loading) {
                    return Skeletonizer(
                      enabled: true,
                      child: ListView.separated(
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          return CommunityCard(
                            c: Community(
                              id: 'dummy',
                              name: 'Loading Community Name',
                              description: 'Loading community description...',
                              ownerId: 'dummy',
                              members: [],
                              joinRequests: [],
                              createdAt: DateTime.now(),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state.status == CommunityStatus.failure) {
                    return Center(child: Text('Error: ${state.error}'));
                  } else if (state.communities.isEmpty) {
                    return Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(S.of(context).noCommunitiesYet),
                        const SizedBox(height: 20),
                        AppTextBtn(
                          buttonText: S.of(context).createFirstCommunity,
                          textStyle: semiBoldStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _showCreateDialog(context);
                          },
                        )
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: state.communities.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: AppTextBtn(
                            buttonText: S.of(context).createCommunity,
                            textStyle: semiBoldStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            onPressed: () => _showCreateDialog(context),
                          ),
                        );
                      }
                      final c = state.communities[i - 1];
                      return CommunityCard(c: c);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).createCommunity),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: S.of(context).communityNameLabel),
            ),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(labelText: S.of(context).communityDescLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              final bloc = context.read<CommunityBloc>();
              final currentUser = await AuthRepository().currentUser;
              final ownerId = currentUser?.uid ?? 'error in creating community';

              if (ownerId.isEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).userNotLoggedIn)),
                );
                return;
              }

              bloc.add(
                CreateCommunityRequested(
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  ownerId: ownerId,
                ),
              );

              Navigator.pop(ctx);
            },
            child: Text(S.of(context).create),
          ),
        ],
      ),
    );
  }
}
