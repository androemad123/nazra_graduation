import 'package:flutter/material.dart';

import '../../app/models/complaint_model.dart';
import '../widgets/complaint_card.dart';
import 'complaint_details_screen.dart';

class ComplainsScreen extends StatelessWidget {
  const ComplainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = Complaint.dummyData; // Use your model's dummyData

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("My Complaints"),
        automaticallyImplyLeading: false,
      ),
      body: complaints.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No complaints yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              'Submit an issue to see it listed here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          return ComplaintCard(
            complaint: complaint,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComplaintDetailsScreen(
                    complaint: complaint,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
