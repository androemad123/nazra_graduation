import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/models/complaint_model.dart';
import '../../../app/repositories/complaint_repository.dart';
import '../../../app/utils/gov_issue_cluster.dart';
import '../../../generated/l10n.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';
import 'admin_complaint_details_screen.dart';
import 'admin_duplicate_clusters_screen.dart';
import 'admin_feedback_screen.dart';
import 'gov_cluster_localizations.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ComplaintRepository _repository = ComplaintRepository();
  String _selectedFilter = 'all'; // all, pending, in_progress, resolved
  String _selectedPrioritySort = 'none'; // none, high_to_low, low_to_high

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          s.complaintManagement,
          style: semiBoldStyle(fontSize: 22, color: Colors.black87),
        ),
        actions: [
          IconButton(
            tooltip: s.duplicateClusters,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminDuplicateClustersScreen(),
                ),
              );
            },
            icon: const Icon(Icons.account_tree_outlined),
          ),
          IconButton(
            tooltip: s.feedbackInbox,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminFeedbackScreen(),
                ),
              );
            },
            icon: const Icon(Icons.feedback_outlined),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEF2F7),
              Color(0xFFF7F9FC),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _repository.watchAllComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('${s.error}: ${snapshot.error}'));
                  }

                  final complaintsData = snapshot.data ?? [];

                  if (complaintsData.isEmpty) {
                    return Center(
                      child: Text(s.noComplaintsYet),
                    );
                  }

                  final complaints = complaintsData
                      .map((data) => Complaint.fromMap(data, data['id'] ?? ''))
                      .toList();

                  final filteredComplaints = _sortComplaintsByPriority(
                    _filterComplaints(complaints),
                  );

                  if (filteredComplaints.isEmpty) {
                    return Center(
                      child: Text(s.noFilteredComplaints),
                    );
                  }

                  final groupedComplaints = _groupComplaintsByGovCluster(
                    filteredComplaints,
                  );
                  final groupedEntries =
                      _orderedGovClusterEntries(groupedComplaints);

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: groupedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = groupedEntries[index];
                      final clusterCode = entry.key;
                      final complaintsInCluster = entry.value;
                      final accent = govClusterAccent(clusterCode);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                govClusterIcon(clusterCode),
                                size: 22,
                                color: accent,
                              ),
                            ),
                            title: Text(
                              govClusterTitle(s, clusterCode),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: semiBoldStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    govClusterSubtitle(s, clusterCode),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: regularStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Text(
                                          clusterCode,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.35,
                                            color: Colors.blueGrey.shade800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          '${complaintsInCluster.length} ${s.complaints}',
                                          style: regularStyle(
                                            fontSize: 12,
                                            color: ColorManager.darkGray,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${complaintsInCluster.length}',
                                style: semiBoldStyle(
                                  fontSize: 13,
                                  color: accent,
                                ),
                              ),
                            ),
                            children: complaintsInCluster
                                .map(
                                  (complaint) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _ComplaintCard(
                                      complaint: complaint,
                                      compact: true,
                                      onTap: () => _navigateToDetails(complaint),
                                    ),
                                  ),
                                )
                                .toList(),
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
      ),
    );
  }

  Widget _buildFilterTabs() {
    final s = S.of(context);
    final filters = ['all', 'pending', 'in_progress', 'resolved'];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(filter, _statusLabel(s, filter)),
              );
            }),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedPrioritySort,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(value: 'none', child: Text(s.prioritySortNone)),
                DropdownMenuItem(value: 'high_to_low', child: Text(s.priorityHighToLow)),
                DropdownMenuItem(value: 'low_to_high', child: Text(s.priorityLowToHigh)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedPrioritySort = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(S s, String status) {
    switch (status) {
      case 'pending':
        return s.pending;
      case 'in_progress':
        return s.inProgress;
      case 'resolved':
        return s.resolved;
      default:
        return s.all;
    }
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD8B075) : ColorManager.lighterGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: regularStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : ColorManager.darkGray,
          ),
        ),
      ),
    );
  }

  List<Complaint> _filterComplaints(List<Complaint> complaints) {
    if (_selectedFilter == 'pending') {
      return complaints.where((c) => c.status == 'pending').toList();
    } else if (_selectedFilter == 'in_progress') {
      return complaints.where((c) => c.status == 'in_progress').toList();
    } else if (_selectedFilter == 'resolved') {
      return complaints.where((c) => c.status == 'resolved').toList();
    }
    return complaints;
  }

  List<Complaint> _sortComplaintsByPriority(List<Complaint> complaints) {
    final sorted = List<Complaint>.from(complaints);
    if (_selectedPrioritySort == 'none') return sorted;

    int rank(String priority) {
      switch (priority.toLowerCase()) {
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

    sorted.sort((a, b) {
      final aRank = rank(a.priority);
      final bRank = rank(b.priority);
      if (_selectedPrioritySort == 'low_to_high') {
        return aRank.compareTo(bRank);
      }
      return bRank.compareTo(aRank);
    });
    return sorted;
  }

  Map<String, List<Complaint>> _groupComplaintsByGovCluster(
    List<Complaint> complaints,
  ) {
    final grouped = <String, List<Complaint>>{};
    for (final complaint in complaints) {
      final code = resolveGovClusterCode(complaint);
      grouped.putIfAbsent(code, () => <Complaint>[]).add(complaint);
    }
    return grouped;
  }

  /// Stable department order; within the same cluster, list follows stream order.
  List<MapEntry<String, List<Complaint>>> _orderedGovClusterEntries(
    Map<String, List<Complaint>> grouped,
  ) {
    final ordered = <MapEntry<String, List<Complaint>>>[];
    for (final code in GovClusterCode.orderedCodes) {
      final list = grouped[code];
      if (list != null && list.isNotEmpty) {
        ordered.add(MapEntry(code, list));
      }
    }
    for (final e in grouped.entries) {
      if (!GovClusterCode.orderedCodes.contains(e.key) && e.value.isNotEmpty) {
        ordered.add(e);
      }
    }
    return ordered;
  }

  void _navigateToDetails(Complaint complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminComplaintDetailsScreen(complaint: complaint),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;
  final bool compact;

  const _ComplaintCard({
    required this.complaint,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final issueTypeLabel = _displayIssueType(complaint);
    final imageSize = compact ? 64.0 : 80.0;
    return Card(
      color: compact ? const Color(0xFFFCFCFC) : Colors.white,
      elevation: compact ? 0.8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: compact
            ? const BorderSide(color: Color(0xFFEDEDED))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail
              if (complaint.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    complaint.imageUrls.first,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: imageSize,
                      height: imageSize,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              if (complaint.imageUrls.isEmpty)
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(width: 12),
              
              // Complaint info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      issueTypeLabel,
                      style: semiBoldStyle(
                        fontSize: compact ? 15 : 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      complaint.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: regularStyle(
                        fontSize: compact ? 13 : 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Status and Priority badges
                    Row(
                      children: [
                        _StatusBadge(status: complaint.status),
                        const SizedBox(width: 8),
                        _PriorityBadge(priority: complaint.priority),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Date
                    Text(
                      _formatDate(complaint.createdAt.toDate()),
                      style: regularStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _displayIssueType(Complaint complaint) {
    final aiIssueType = complaint.aiAnalysis?.issueType?.trim();
    if (aiIssueType != null && aiIssueType.isNotEmpty) {
      return aiIssueType
          .split('_')
          .where((e) => e.isNotEmpty)
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
    }
    final category = complaint.category.trim();
    if (category.isNotEmpty) return category;
    return 'Unknown';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = s.pending;
        break;
      case 'in_progress':
        color = Colors.blue;
        label = s.inProgress;
        break;
      case 'resolved':
        color = Colors.green;
        label = s.resolved;
        break;
      case 'not_issue':
        color = Colors.grey;
        label = s.notIssue;
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (priority.toLowerCase()) {
      case 'emergency':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.deepOrange;
        break;
      case 'medium':
        color = Colors.amber;
        break;
      case 'low':
        color = Colors.lightGreen;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
