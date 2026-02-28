import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _dailyData = [];
  DateTime _selectedDate = DateTime.now();
  List<MedicineLog> _selectedDayLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _stats = MedicineService.getWeeklyStats();
      _dailyData = MedicineService.getDailyAdherence(days: 14);
      _selectedDayLogs = MedicineService.getLogsForDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: AppTheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Day Log'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverview(),
              _buildDayLog(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverview() {
    final total = _stats['total'] as int? ?? 0;
    final taken = _stats['taken'] as int? ?? 0;
    final missed = _stats['missed'] as int? ?? 0;
    final adherence = _stats['adherence'] as double? ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Weekly Stats Header
        const Text(
          'Last 7 Days',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Adherence Ring
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: adherence / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '${adherence.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adherence Rate',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adherence >= 80
                          ? 'Excellent! 🎉'
                          : adherence >= 60
                              ? 'Good job! 💪'
                              : 'Keep improving 📈',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatRow(label: 'Taken', value: '$taken', color: Colors.white),
                    _StatRow(
                        label: 'Missed',
                        value: '$missed',
                        color: Colors.white70),
                    _StatRow(
                        label: 'Total',
                        value: '$total',
                        color: Colors.white60),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Chart
        const Text(
          '14-Day Trend',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _dailyData.isEmpty
              ? const Center(
                  child: Text('Not enough data yet',
                      style: TextStyle(color: AppTheme.textSecondary)))
              : BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
                            if (idx >= _dailyData.length || idx < 0)
                              return const SizedBox.shrink();
                            final date =
                                _dailyData[idx]['date'] as DateTime;
                            if (idx % 3 != 0) return const SizedBox.shrink();
                            return Text(
                              DateFormat('M/d').format(date),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: _dailyData.asMap().entries.map((e) {
                      final i = e.key;
                      final d = e.value;
                      final val = (d['adherence'] as double) * 100;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: val,
                            color: val >= 80
                                ? AppTheme.success
                                : val >= 50
                                    ? AppTheme.warning
                                    : AppTheme.error,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 100,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    maxY: 100,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: AppTheme.success, label: '≥80%'),
            const SizedBox(width: 16),
            _Legend(color: AppTheme.warning, label: '50–79%'),
            const SizedBox(width: 16),
            _Legend(color: AppTheme.error, label: '<50%'),
          ],
        ),
      ],
    );
  }

  Widget _buildDayLog() {
    return Column(
      children: [
        // Date selector
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: 30,
            itemBuilder: (ctx, i) {
              final date = DateTime.now().subtract(Duration(days: 29 - i));
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedDayLogs =
                        MedicineService.getLogsForDate(date);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white70
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 17,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Log list
        Expanded(
          child: _selectedDayLogs.isEmpty
              ? const Center(
                  child: Text(
                    'No records for this day',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _selectedDayLogs.length,
                  itemBuilder: (ctx, i) {
                    final log = _selectedDayLogs[i];
                    return _HistoryLogTile(log: log);
                  },
                ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _HistoryLogTile extends StatelessWidget {
  final MedicineLog log;
  const _HistoryLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (log.status) {
      case LogStatus.taken:
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        statusText = 'Taken';
        break;
      case LogStatus.missed:
        statusColor = AppTheme.error;
        statusIcon = Icons.cancel;
        statusText = 'Missed';
        break;
      case LogStatus.skipped:
        statusColor = AppTheme.warning;
        statusIcon = Icons.skip_next;
        statusText = 'Skipped';
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.radio_button_unchecked;
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.medicineName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
                ),
                Text(
                  '${log.dosage} • ${DateFormat('hh:mm a').format(log.scheduledTime)}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
