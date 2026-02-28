import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const MedicineCard({super.key, required this.medicine});

  Color get _color {
    try {
      return Color(int.parse('FF${medicine.color}', radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pill icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: _color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medicine.dosage,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (medicine.instructions.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    medicine.instructions,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Time chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: medicine.times.map((t) {
                    final parts = t.split(':');
                    int h = int.parse(parts[0]);
                    final m = parts[1];
                    final period = h >= 12 ? 'PM' : 'AM';
                    if (h > 12) h -= 12;
                    if (h == 0) h = 12;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$h:$m $period',
                        style: TextStyle(
                          color: _color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Active indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: medicine.isActive ? AppTheme.success : AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
