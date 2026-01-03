import 'package:flutter/material.dart';

class CommunityMembersScreen extends StatelessWidget {
  final String communityId;

  const CommunityMembersScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: const Text('Members')));
  }
}
