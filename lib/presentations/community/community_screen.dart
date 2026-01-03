import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../resources/styles_manager.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Fake placeholder communities
  final List<Map<String, String>> _communities = [
    {
      'name': 'Community A',
      'description': 'Description of Community A',
    },
    {
      'name': 'Community B',
      'description': 'Description of Community B',
    },
    {
      'name': 'Community C',
      'description': 'Description of Community C',
    },
  ];

  bool _isLoading = false; // fake loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Communities',
          style: semiBoldStyle(fontSize: 22, color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _isLoading
            ? Skeletonizer(
          enabled: true, child: Placeholder(),

        )
            : _communities.isEmpty
            ? Column(
          children: [
            const SizedBox(height: 40),
            const Text('No communities yet'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Create First Community'),
            )
          ],
        )
            : ListView.separated(
          itemCount: _communities.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Create Community'),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
