import 'package:flutter/material.dart';

import '../../../app/models/complaint_model.dart';
import '../../../app/models/complaint_feedback.dart';
import '../../../app/repositories/complaint_repository.dart';
import '../../../app/repositories/complaint_feedback_repository.dart';
import '../../../generated/l10n.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';
import 'admin_complaint_details_screen.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final ComplaintFeedbackRepository _repository = ComplaintFeedbackRepository();
  final ComplaintRepository _complaintRepository = ComplaintRepository();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.feedbackInbox),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip('all', s.all),
                const SizedBox(width: 8),
                _chip('open', s.open),
                const SizedBox(width: 8),
                _chip('resolved', s.resolved),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ComplaintFeedback>>(
              stream: _repository.watchAllFeedback(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var list = snap.data!;
                if (_filter == 'open') {
                  list = list
                      .where((e) => e.status == ComplaintFeedbackStatus.open)
                      .toList();
                } else if (_filter == 'resolved') {
                  list = list
                      .where((e) => e.status == ComplaintFeedbackStatus.resolved)
                      .toList();
                }

                list.sort((a, b) {
                  final urg = (b.severity == ComplaintFeedbackSeverity.urgent ? 1 : 0)
                      .compareTo(a.severity == ComplaintFeedbackSeverity.urgent ? 1 : 0);
                  if (urg != 0) return urg;
                  return b.createdAt.compareTo(a.createdAt);
                });

                if (list.isEmpty) {
                  return Center(child: Text(s.noFeedbackYet));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = list[i];
                    final isUrgent = item.severity == ComplaintFeedbackSeverity.urgent;
                    return InkWell(
                      onTap: () => _openComplaintDetails(item.complaintId),
                      borderRadius: BorderRadius.circular(14),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isUrgent ? Colors.red.shade200 : Colors.grey.shade200,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${s.complaintIdLabel}: ${item.complaintId}',
                                      style: semiBoldStyle(
                                        fontSize: 14,
                                        color: ColorManager.darkBrown,
                                      ),
                                    ),
                                  ),
                                  if (isUrgent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        s.urgent,
                                        style: semiBoldStyle(fontSize: 11, color: Colors.red),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right, color: Colors.grey.shade500),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.message.isEmpty ? s.noMessageProvided : item.message,
                                style: regularStyle(fontSize: 13, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${s.complaintAgeDays}: ${item.complaintAgeDays} • ${s.thresholdDays}: ${item.thresholdDays}',
                                style: regularStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.status == ComplaintFeedbackStatus.resolved
                                          ? Colors.green.shade50
                                          : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.status == ComplaintFeedbackStatus.resolved ? s.resolved : s.open,
                                      style: regularStyle(
                                        fontSize: 11,
                                        color: item.status == ComplaintFeedbackStatus.resolved
                                            ? Colors.green
                                            : Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (item.status != ComplaintFeedbackStatus.resolved)
                                    TextButton(
                                      onPressed: () async {
                                        await _repository.markResolved(item.id);
                                      },
                                      child: Text(s.markResolved),
                                    ),
                                ],
                              ),
                            ],
                          ),
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
    );
  }

  Widget _chip(String value, String label) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected ? ColorManager.brown : ColorManager.lighterGray,
        ),
        child: Text(
          label,
          style: regularStyle(
            fontSize: 13,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _openComplaintDetails(String complaintId) async {
    final data = await _complaintRepository.getComplaintById(complaintId);
    if (!mounted) return;
    if (data == null) {
      final s = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.error}: ${s.noDataAvailable}')),
      );
      return;
    }

    final complaint = Complaint.fromMap(data, data['id'] ?? complaintId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminComplaintDetailsScreen(complaint: complaint),
      ),
    );
  }
}

