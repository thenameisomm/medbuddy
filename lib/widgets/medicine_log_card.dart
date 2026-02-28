import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';

class MedicineLogCard extends StatelessWidget {
  final MedicineLog log;
  final VoidCallback onTaken;
  final VoidCallback onSkipped;

  const MedicineLogCard({
    super.key,
    required this.log,
    required this.onTaken,
    required this.onSkipped,
  });

  Color get _statusColor {
    switch (log.status) {
      case LogStatus.taken:
        return AppTheme.success;
      case LogStatus.missed:
        return AppTheme.error;
      case LogStatus.skipped:
        return AppTheme.warning;
      default:
        return _isUpcoming ? AppTheme.primary : AppTheme.warning;
    }
  }

  bool get _isUpcoming =>
      log.scheduledTime.isAfter(DateTime.now());

  bool get _isPending => log.status == LogStatus.pending;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(log.scheduledTime);
    final isPast = log.scheduledTime.isBefore(DateTime.now());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: log.status == LogStatus.taken
              ? AppTheme.success.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time column
            SizedBox(
              width: 62,
              child: Column(
                children: [
                  Text(
                    timeStr.split(' ')[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    timeStr.split(' ')[1],
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Divider line
            Container(
              width: 2,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Medicine info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.medicineName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: log.status == LogStatus.taken
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      decoration: log.status == LogStatus.taken
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log.dosage,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Status / Actions
            if (log.status == LogStatus.taken)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: AppTheme.success, size: 20),
              )
            else if (log.status == LogStatus.missed)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Missed',
                  style: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              )
            else if (log.status == LogStatus.skipped)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Skipped',
                  style: TextStyle(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              )
            else
              Row(
                children: [
                  GestureDetector(
                    onTap: onSkipped,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: AppTheme.warning, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onTaken,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Taken ✓',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
