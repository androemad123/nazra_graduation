import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app/bloc/community/community_bloc.dart';
import '../../app/bloc/community/community_event.dart';
import '../../app/bloc/issue/issue_bloc.dart';
import '../../app/bloc/issue/issue_event.dart';
import '../../app/bloc/issue/issue_state.dart';
import '../../app/models/community.dart';
import '../../app/repositories/community_repository.dart';
import '../../app/repositories/issue_repository.dart';

import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../widgets/issue_card.dart';
import 'add_issue_screen.dart';
import 'issue_details_screen.dart';
import 'join_request_screen.dart';
import 'community_members_screen.dart';

class CommunityDetailsScreen extends StatelessWidget {
  final String communityId;

  const CommunityDetailsScreen({
    super.key,
    required this.communityId,
  });

  @override
  Widget build(BuildContext context) {
    final communityRepo = CommunityRepository();
    final issueRepo = IssueRepository();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CommunityBloc(repo: communityRepo),
        ),
        BlocProvider(
          create: (_) => IssueBloc(repo: issueRepo),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Community')),
        body: StreamBuilder<Community?>(
          stream: communityRepo.watchCommunity(communityId),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final community = snap.data!;
            final isOwner = community.ownerId == currentUserId;
            final isMember = community.members.contains(currentUserId);

            /// 🔐 Load issues ONLY if user is a member
            if (isMember) {
              final issueBloc = context.read<IssueBloc>();
                issueBloc.add(LoadCommunityIssues(communityId));

            }

            return CustomScrollView(
              slivers: [
                /// ================= HEADER =================
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                community.name,
                                style: semiBoldStyle(
                                  fontSize: 28,
                                  color: ColorManager.darkBrown,
                                ),
                              ),
                            ),
                            if (isOwner)
                              IconButton(
                                icon: const Icon(Icons.people_alt_rounded),
                                color: ColorManager.brown,
                                tooltip: 'Manage join requests',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JoinRequestsScreen(
                                        communityId: community.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          community.description,
                          style: regularStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// ================= MEMBERS =================
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommunityMembersScreen(
                                      communityId: community.id,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorManager.lighterBeige,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.group,
                                      size: 18,
                                      color: ColorManager.brown,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${community.members.length} members',
                                      style: semiBoldStyle(
                                        fontSize: 14,
                                        color: ColorManager.brown,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),

                            /// ================= JOIN BUTTON =================
                            if (!isMember)
                              ElevatedButton(
                                onPressed: () {
                                  if (currentUserId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please login to join'),
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<CommunityBloc>().add(
                                    RequestJoinCommunity(
                                      community.id,
                                      currentUserId,
                                    ),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Join request sent'),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.brown,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Request to join',
                                  style: semiBoldStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /// ================= ISSUES TITLE =================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      "Community Issues",
                      style: semiBoldStyle(
                        fontSize: 20,
                        color: ColorManager.darkBrown,
                      ),
                    ),
                  ),
                ),

                /// ================= ISSUES CONTENT =================
                if (!isMember)
                /// 🔒 LOCKED STATE
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Join this community to view issues',
                            style: semiBoldStyle(fontSize: 19,color: ColorManager.brown),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Issues are visible to members only',
                            style: regularStyle(color: Colors.grey,fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                /// ✅ MEMBER VIEW
                  BlocBuilder<IssueBloc, IssueState>(
                    builder: (context, state) {
                      if (state.status == IssueStatus.loading) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      if (state.issues.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text('No issues yet'),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final issue = state.issues[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: IssueCard(
                                issue: issue,
                                hasUserVoted:
                                issue.hasUserVoted(currentUserId),
                                onVote: () {
                                  if (issue.hasUserVoted(currentUserId)) {
                                    context.read<IssueBloc>().add(
                                      UnvoteIssueRequested(issue.id),
                                    );
                                  } else {
                                    context.read<IssueBloc>().add(
                                      VoteIssueRequested(issue.id),
                                    );
                                  }
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => IssueDetailsScreen(
                                        issueId: issue.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: state.issues.length,
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),

        /// ================= FAB =================
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                if (currentUserId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login to add an issue'),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<IssueBloc>(),
                      child: AddIssueScreen(
                        communityId: communityId,
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
