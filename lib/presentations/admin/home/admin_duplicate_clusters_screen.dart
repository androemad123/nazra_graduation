import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../app/models/complaint_model.dart';
import '../../../app/repositories/complaint_repository.dart';
import '../../../generated/l10n.dart';
import '../../resources/styles_manager.dart';
import 'admin_complaint_details_screen.dart';

class AdminDuplicateClustersScreen extends StatefulWidget {
  const AdminDuplicateClustersScreen({super.key});

  @override
  State<AdminDuplicateClustersScreen> createState() =>
      _AdminDuplicateClustersScreenState();
}

class _AdminDuplicateClustersScreenState
    extends State<AdminDuplicateClustersScreen> {
  final ComplaintRepository _repository = ComplaintRepository();
  final Set<String> _openingClusters = <String>{};

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.duplicateClusters),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.watchAllComplaints(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!
              .map((m) => Complaint.fromMap(m, m['id'] ?? ''))
              .toList();

          final clusters = <String, List<Complaint>>{};
          for (final c in all) {
            final clusterId = (c.clusterId ?? c.id).trim();
            clusters.putIfAbsent(clusterId, () => []).add(c);
          }
          final grouped = clusters.entries.where((e) => e.value.length > 1).toList();

          // Fallback/inferred clusters for old data that was never linked with clusterId.
          final inferred = _inferDuplicateClusters(all);
          for (final inf in inferred.entries) {
            if (!grouped.any((e) => _sameComplaintSet(e.value, inf.value))) {
              grouped.add(inf);
            }
          }

          // Hide clusters that are already fully resolved.
          grouped.removeWhere(
            (entry) =>
                entry.value.isNotEmpty &&
                entry.value.every(
                  (c) =>
                      c.status.trim().toLowerCase() == 'resolved' ||
                      c.status.trim().toLowerCase() == 'not_issue',
                ),
          );

          grouped.sort((a, b) {
            final p = _clusterPriorityScore(b.value).compareTo(
              _clusterPriorityScore(a.value),
            );
            if (p != 0) return p;
            return b.value.length.compareTo(a.value.length);
          });

          if (grouped.isEmpty) {
            return Center(child: Text(s.noDuplicateClusters));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: grouped.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final entry = grouped[i];
              final items = entry.value;
              final canonical = items.firstWhere(
                (e) => e.duplicateOf == null,
                orElse: () => items.first,
              );
              final highestPriority = _highestPriorityLabel(items);
              final opening = _openingClusters.contains(entry.key);
              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: opening
                      ? null
                      : () async {
                          setState(() {
                            _openingClusters.add(entry.key);
                          });
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _ClusterComplaintsScreen(
                                clusterId: entry.key,
                                complaints: items,
                                canonicalComplaintId: canonical.id,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {
                            _openingClusters.remove(entry.key);
                          });
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE7DA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.folder_copy_outlined),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${s.clusterLabel}: ${entry.key}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: semiBoldStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${s.clusterItemsCount}: ${items.length}',
                                style: regularStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PriorityPill(priorityLabel: highestPriority),
                        const SizedBox(width: 8),
                        opening
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<Complaint>> _inferDuplicateClusters(List<Complaint> complaints) {
    const maxDistanceMeters = 250.0;
    const maxDaysGap = 14;

    final byType = <String, List<Complaint>>{};
    for (final c in complaints) {
      final type = _normalizedType(c);
      byType.putIfAbsent(type, () => []).add(c);
    }

    final result = <String, List<Complaint>>{};
    var index = 0;

    for (final entry in byType.entries) {
      final items = entry.value..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final localClusters = <List<Complaint>>[];

      for (final c in items) {
        bool added = false;
        for (final cluster in localClusters) {
          final seed = cluster.first;
          final dist = Geolocator.distanceBetween(
            c.location.latitude,
            c.location.longitude,
            seed.location.latitude,
            seed.location.longitude,
          );
          final days = c.createdAt.toDate().difference(seed.createdAt.toDate()).inDays.abs();

          if (dist <= maxDistanceMeters && days <= maxDaysGap) {
            cluster.add(c);
            added = true;
            break;
          }
        }
        if (!added) {
          localClusters.add([c]);
        }
      }

      for (final cluster in localClusters.where((c) => c.length > 1)) {
        result['inferred_${entry.key}_${index++}'] = cluster;
      }
    }

    return result;
  }

  String _normalizedType(Complaint c) {
    final ai = c.aiAnalysis?.issueType?.trim();
    if (ai != null && ai.isNotEmpty) return ai.toLowerCase();
    final cat = c.category.trim();
    if (cat.isNotEmpty) return cat.toLowerCase().replaceAll(' ', '_');
    return 'unknown';
  }

  bool _sameComplaintSet(List<Complaint> a, List<Complaint> b) {
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.length == bIds.length && aIds.containsAll(bIds);
  }

  int _clusterPriorityScore(List<Complaint> complaints) {
    var best = 0;
    for (final c in complaints) {
      final p = _priorityScore(c.priority);
      if (p > best) best = p;
    }
    return best;
  }

  int _priorityScore(String value) {
    switch (value.trim().toLowerCase()) {
      case 'emergency':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  String _highestPriorityLabel(List<Complaint> complaints) {
    final ranked = ['low', 'medium', 'high', 'emergency'];
    String best = 'low';
    var score = -1;
    for (final c in complaints) {
      final s = _priorityScore(c.priority);
      if (s > score) {
        score = s;
        best = c.priority.toLowerCase().trim();
      }
    }
    if (!ranked.contains(best)) return 'low';
    return best;
  }
}

class _ClusterComplaintsScreen extends StatefulWidget {
  final String clusterId;
  final List<Complaint> complaints;
  final String canonicalComplaintId;

  const _ClusterComplaintsScreen({
    required this.clusterId,
    required this.complaints,
    required this.canonicalComplaintId,
  });

  @override
  State<_ClusterComplaintsScreen> createState() => _ClusterComplaintsScreenState();
}

class _ClusterComplaintsScreenState extends State<_ClusterComplaintsScreen> {
  final ComplaintRepository _repository = ComplaintRepository();
  late String _canonicalId;
  late final Set<String> _clusterComplaintIds;

  @override
  void initState() {
    super.initState();
    _canonicalId = widget.canonicalComplaintId;
    _clusterComplaintIds = widget.complaints.map((c) => c.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.clusterLabel}: ${widget.clusterId}'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.watchAllComplaints(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final liveComplaints = snap.data!
              .map((m) => Complaint.fromMap(m, m['id'] ?? ''))
              .where((c) => _clusterComplaintIds.contains(c.id))
              .toList()
            ..sort((a, b) {
              final p = _priorityScore(b.priority).compareTo(
                _priorityScore(a.priority),
              );
              if (p != 0) return p;
              return b.createdAt.compareTo(a.createdAt);
            });

          if (liveComplaints.isEmpty) {
            return Center(child: Text(s.noDataAvailable));
          }

          if (!liveComplaints.any((c) => c.id == _canonicalId)) {
            _canonicalId = liveComplaints.first.id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final complaint in liveComplaints) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  complaint.aiAnalysis?.issueType ??
                                      complaint.category,
                                  style: semiBoldStyle(fontSize: 15, color: Colors.black87),
                                ),
                              ),
                              if (complaint.id == _canonicalId)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'CANONICAL',
                                    style: regularStyle(fontSize: 11, color: Colors.green),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            complaint.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: regularStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ID: ${complaint.id}',
                            style: regularStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showStatusDialog(complaint, liveComplaints),
                                icon: const Icon(Icons.edit_outlined),
                                label: Text(s.updateStatus),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _applyQuickStatus(
                                  complaint: complaint,
                                  currentCluster: liveComplaints,
                                  status: 'resolved',
                                  successLabel: s.resolved,
                                ),
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text(s.resolved),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _applyQuickStatus(
                                  complaint: complaint,
                                  currentCluster: liveComplaints,
                                  status: 'resolved',
                                  successLabel: s.fixed,
                                ),
                                icon: const Icon(Icons.build_circle_outlined),
                                label: Text(s.fixed),
                              ),
                              if (complaint.id != _canonicalId)
                                TextButton.icon(
                                  onPressed: () => _markDuplicate(complaint.id),
                                  icon: const Icon(Icons.link_outlined),
                                  label: Text(s.markAsDuplicate),
                                ),
                              IconButton(
                                tooltip: s.details,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminComplaintDetailsScreen(complaint: complaint),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.open_in_new),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showStatusDialog(Complaint complaint, List<Complaint> currentCluster) async {
    final s = S.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.updateStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.pending),
              onTap: () => Navigator.pop(ctx, 'pending'),
            ),
            ListTile(
              title: Text(s.inProgress),
              onTap: () => Navigator.pop(ctx, 'in_progress'),
            ),
            ListTile(
              title: Text(s.resolved),
              onTap: () => Navigator.pop(ctx, 'resolved'),
            ),
            ListTile(
              title: Text(s.notIssue),
              onTap: () => Navigator.pop(ctx, 'not_issue'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;
    if (complaint.id == _canonicalId) {
      final ids = currentCluster.map((c) => c.id).toList();
      await _repository.updateComplaintStatusesBatch(ids, result);
    } else {
      await _repository.updateComplaintStatus(complaint.id, result);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          complaint.id == _canonicalId
              ? '${s.statusUpdatedTo} $result (${currentCluster.length} items)'
              : '${s.statusUpdatedTo} $result',
        ),
      ),
    );
  }

  Future<void> _markDuplicate(String complaintId) async {
    final s = S.of(context);
    await _repository.markAsDuplicate(
      complaintId: complaintId,
      canonicalComplaintId: _canonicalId,
      confidence: 0.9,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.duplicateMarkedSuccess)),
    );
    setState(() {});
  }

  int _priorityScore(String value) {
    switch (value.trim().toLowerCase()) {
      case 'emergency':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  Future<void> _applyQuickStatus({
    required Complaint complaint,
    required List<Complaint> currentCluster,
    required String status,
    required String successLabel,
  }) async {
    final s = S.of(context);
    if (complaint.id == _canonicalId) {
      final ids = currentCluster.map((c) => c.id).toList();
      await _repository.updateComplaintStatusesBatch(ids, status);
    } else {
      await _repository.updateComplaintStatus(complaint.id, status);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          complaint.id == _canonicalId
              ? '${s.statusUpdatedTo} $successLabel (${currentCluster.length} items)'
              : '${s.statusUpdatedTo} $successLabel',
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final String priorityLabel;

  const _PriorityPill({required this.priorityLabel});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priorityLabel) {
      case 'emergency':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.deepOrange;
        break;
      case 'medium':
        color = Colors.amber.shade700;
        break;
      default:
        color = Colors.lightGreen.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priorityLabel.toUpperCase(),
        style: regularStyle(fontSize: 10, color: color),
      ),
    );
  }
}

