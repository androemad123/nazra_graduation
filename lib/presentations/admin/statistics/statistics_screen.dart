import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../../app/models/complaint_model.dart';
import '../../../app/repositories/complaint_repository.dart';
import '../../../generated/l10n.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ComplaintRepository _repository = ComplaintRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          S.of(context).statistics,
          style: semiBoldStyle(fontSize: 22, color: Colors.black87),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.watchAllComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final complaintsData = snapshot.data ?? [];
          final complaints = complaintsData
              .map((data) => Complaint.fromMap(data, data['id'] ?? ''))
              .toList();

          final stats = _calculateStatistics(complaints);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(stats),
                const SizedBox(height: 24),

                // Status Distribution Chart
                Text(
                  S.of(context).statusDistribution,
                  style: semiBoldStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildStatusPieChart(stats),
                const SizedBox(height: 24),

                // Priority Distribution
                Text(
                  S.of(context).priorityDistribution,
                  style: semiBoldStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildPriorityBarChart(stats),
                const SizedBox(height: 24),

                // Category Breakdown
                Text(
                  S.of(context).topCategories,
                  style: semiBoldStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildCategoryList(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _calculateStatistics(List<Complaint> complaints) {
    final total = complaints.length;
    final pending = complaints.where((c) => c.status == 'pending').length;
    final inProgress = complaints.where((c) => c.status == 'in_progress').length;
    final resolved = complaints.where((c) => c.status == 'resolved').length;
    final notIssue = complaints.where((c) => c.status == 'not_issue').length;

    final emergency = complaints.where((c) => c.priority.toLowerCase() == 'emergency').length;
    final high = complaints.where((c) => c.priority.toLowerCase() == 'high').length;
    final medium = complaints.where((c) => c.priority.toLowerCase() == 'medium').length;
    final low = complaints.where((c) => c.priority.toLowerCase() == 'low').length;

    // Category counts
    final categoryMap = <String, int>{};
    for (var complaint in complaints) {
      categoryMap[complaint.category] = (categoryMap[complaint.category] ?? 0) + 1;
    }
    final topCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'resolved': resolved,
      'notIssue': notIssue,
      'emergency': emergency,
      'high': high,
      'medium': medium,
      'low': low,
      'categories': topCategories.take(5).toList(),
    };
  }

  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _SummaryCard(
          title: S.of(context).totalComplaints,
          value: stats['total'].toString(),
          color: ColorManager.lightBrown,
          icon: Icons.list_alt,
        ),
        _SummaryCard(
          title: S.of(context).pending,
          value: stats['pending'].toString(),
          color: Colors.orange,
          icon: Icons.pending_actions,
        ),
        _SummaryCard(
          title: S.of(context).inProgress,
          value: stats['inProgress'].toString(),
          color: Colors.blue,
          icon: Icons.autorenew,
        ),
        _SummaryCard(
          title: S.of(context).resolved,
          value: stats['resolved'].toString(),
          color: Colors.green,
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildStatusPieChart(Map<String, dynamic> stats) {
    final total = stats['total'] as int;
    if (total == 0) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(S.of(context).noDataAvailable),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: (stats['pending'] as int).toDouble(),
              title: '${stats['pending']}',
              color: Colors.orange,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: (stats['inProgress'] as int).toDouble(),
              title: '${stats['inProgress']}',
              color: Colors.blue,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: (stats['resolved'] as int).toDouble(),
              title: '${stats['resolved']}',
              color: Colors.green,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (stats['notIssue'] > 0)
              PieChartSectionData(
                value: (stats['notIssue'] as int).toDouble(),
                title: '${stats['notIssue']}',
                color: Colors.grey,
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildPriorityBarChart(Map<String, dynamic> stats) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxPriorityValue(stats).toDouble() + 2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text(S.of(context).emergency, style: const TextStyle(fontSize: 10));
                    case 1:
                      return Text(S.of(context).high, style: const TextStyle(fontSize: 10));
                    case 2:
                      return Text(S.of(context).medium, style: const TextStyle(fontSize: 10));
                    case 3:
                      return Text(S.of(context).low, style: const TextStyle(fontSize: 10));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: (stats['emergency'] as int).toDouble(),
                  color: Colors.red,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: (stats['high'] as int).toDouble(),
                  color: Colors.deepOrange,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: (stats['medium'] as int).toDouble(),
                  color: Colors.amber,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: (stats['low'] as int).toDouble(),
                  color: Colors.lightGreen,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getMaxPriorityValue(Map<String, dynamic> stats) {
    return [
      stats['emergency'] as int,
      stats['high'] as int,
      stats['medium'] as int,
      stats['low'] as int,
    ].reduce((a, b) => a > b ? a : b);
  }

  Widget _buildCategoryList(Map<String, dynamic> stats) {
    final categories = stats['categories'] as List<MapEntry<String, int>>;
    
    if (categories.isEmpty) {
      return  Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(S.of(context).noCategoriesYet),
        ),
      );
    }

    return Column(
      children: categories.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.key,
                  style: regularStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorManager.lightBrown.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entry.value}',
                  style: semiBoldStyle(fontSize: 14, color: ColorManager.lightBrown),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                value,
                style: semiBoldStyle(fontSize: 24, color: Colors.black87),
              ),
            ],
          ),
          Text(
            title,
            style: regularStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
