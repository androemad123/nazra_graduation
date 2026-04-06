import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/bloc/complaint/complaint_bloc.dart';
import '../../app/bloc/complaint/complaint_event.dart';
import '../../app/bloc/complaint/complaint_state.dart';
import '../../app/repositories/complaint_repository.dart';
import '../../generated/l10n.dart';
import '../widgets/complaint_card.dart';
import 'complaint_details_screen.dart';

class ComplainsScreen extends StatelessWidget {
  const ComplainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplaintBloc(repo: ComplaintRepository())
        ..add(LoadUserComplaints()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: Text(S.of(context).myComplaints),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<ComplaintBloc, ComplaintState>(
          builder: (context, state) {
            final s = S.of(context);
            if (state.status == ComplaintStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ComplaintStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.error ?? s.failedToLoadComplaints,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ComplaintBloc>().add(LoadUserComplaints());
                      },
                      child: Text(s.retry),
                    ),
                  ],
                ),
              );
            }

            if (state.complaints.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      s.noComplaintsYet,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.submitIssueHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ComplaintBloc>().add(LoadUserComplaints());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.complaints.length,
                itemBuilder: (context, index) {
                  final complaint = state.complaints[index];
                  return ComplaintCard(
                    complaint: complaint,
                    onDetailsPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ComplaintDetailsScreen(complaint: complaint),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
