import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/models/complaint_model.dart';
import '../../../app/repositories/complaint_repository.dart';
import '../../../generated/l10n.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';
import 'admin_complaint_details_screen.dart';
import 'admin_duplicate_clusters_screen.dart';
import 'admin_feedback_screen.dart';

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
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),
          
          // Complaint List
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

                // Filter complaints based on selected filter
                final filteredComplaints = _sortComplaintsByPriority(
                  _filterComplaints(complaints),
                );

                if (filteredComplaints.isEmpty) {
                  return Center(
                    child: Text(s.noFilteredComplaints),
                  );
                }

                final groupedComplaints = _groupComplaintsByCategory(
                  filteredComplaints,
                );
                final groupedEntries = groupedComplaints.entries.toList()
                  ..sort((a, b) => b.value.length.compareTo(a.value.length));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: groupedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = groupedEntries[index];
                    final category = entry.key;
                    final complaintsInCategory = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE7D8C1),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
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
                          tilePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          leading: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4E6D3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.folder_open_outlined,
                              size: 20,
                              color: Color(0xFF8B6A42),
                            ),
                          ),
                          title: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: semiBoldStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            '${complaintsInCategory.length} complaint(s)',
                            style: regularStyle(
                              fontSize: 12,
                              color: ColorManager.darkGray,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${complaintsInCategory.length}',
                              style: semiBoldStyle(
                                fontSize: 12,
                                color: const Color(0xFF8B6A42),
                              ),
                            ),
                          ),
                          children: complaintsInCategory
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
    );
  }

  Widget _buildFilterTabs() {
    final s = S.of(context);
    final filters = ['all', 'pending', 'in_progress', 'resolved'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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

  Map<String, List<Complaint>> _groupComplaintsByCategory(
    List<Complaint> complaints,
  ) {
    final grouped = <String, List<Complaint>>{};
    for (final complaint in complaints) {
      final key = _displayIssueType(complaint);
      grouped.putIfAbsent(key, () => <Complaint>[]).add(complaint);
    }
    return grouped;
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
        color: color.withOpacity(0.2),
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
        color: color.withOpacity(0.2),
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
