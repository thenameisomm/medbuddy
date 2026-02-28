import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  final String? prefillName;
  final String? prefillDosage;
  final List<String>? prefillTimes;
  final String? prefillInstructions;

  const AddMedicineScreen({
    super.key,
    this.medicine,
    this.prefillName,
    this.prefillDosage,
    this.prefillTimes,
    this.prefillInstructions,
  });

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _instructionsCtrl;
  List<TimeOfDay> _times = [];
  late DateTime _startDate;
  late DateTime _endDate;
  late int _selectedColorIndex;
  bool _saving = false;

  bool get _isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    final med = widget.medicine;

    _nameCtrl = TextEditingController(
        text: med?.name ?? widget.prefillName ?? '');
    _dosageCtrl = TextEditingController(
        text: med?.dosage ?? widget.prefillDosage ?? '');
    _instructionsCtrl = TextEditingController(
        text: med?.instructions ?? widget.prefillInstructions ?? '');
    _startDate = med?.startDate ?? DateTime.now();
    _endDate = med?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _selectedColorIndex = AppTheme.pillColors.indexWhere(
        (c) => c.value.toRadixString(16) == (med?.color ?? ''));
    if (_selectedColorIndex < 0) _selectedColorIndex = 0;

    // Parse times
    final prefillTimes = med?.times ?? widget.prefillTimes ?? [];
    _times = prefillTimes.map((t) {
      final parts = t.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _times.add(picked);
        _times.sort((a, b) =>
            (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      });
    }
  }

  void _removeTime(int index) {
    setState(() => _times.removeAt(index));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: isStart ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one reminder time')),
      );
      return;
    }

    setState(() { _saving = true; });

    final timeStrings = _times
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();

    final color = AppTheme.pillColors[_selectedColorIndex]
        .value
        .toRadixString(16)
        .substring(2);

    if (_isEditing) {
      final med = widget.medicine!;
      med.name = _nameCtrl.text.trim();
      med.dosage = _dosageCtrl.text.trim();
      med.times = timeStrings;
      med.color = color;
      med.instructions = _instructionsCtrl.text.trim();
      med.startDate = _startDate;
      med.endDate = _endDate;
      await MedicineService.updateMedicine(med);
    } else {
      final med = Medicine(
        name: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim(),
        times: timeStrings,
        color: color,
        instructions: _instructionsCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      );
      await MedicineService.addMedicine(med);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Medicine' : 'Add Medicine'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Color Picker ─────────────────────────────────────
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppTheme.pillColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final selected = i == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 52 : 40,
                      height: selected ? 52 : 40,
                      decoration: BoxDecoration(
                        color: AppTheme.pillColors[i],
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: AppTheme.pillColors[i].withOpacity(0.5),
                                width: 4)
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppTheme.pillColors[i].withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Name ─────────────────────────────────────────────
            _SectionLabel(label: 'Medicine Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Paracetamol, Amoxicillin...',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter medicine name' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // ── Dosage ───────────────────────────────────────────
            _SectionLabel(label: 'Dosage'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dosageCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. 500mg, 1 Tablet, 5ml...',
                prefixIcon: Icon(Icons.local_pharmacy_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter dosage' : null,
            ),
            const SizedBox(height: 20),

            // ── Times ────────────────────────────────────────────
            _SectionLabel(label: 'Reminder Times'),
            const SizedBox(height: 8),
            ..._times.asMap().entries.map((e) {
              final i = e.key;
              final t = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_outlined,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      t.format(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _removeTime(i),
                      child: const Icon(Icons.remove_circle_outline,
                          color: AppTheme.error, size: 22),
                    ),
                  ],
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.add_alarm_outlined),
              label: const Text('Add Time'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // ── Instructions ─────────────────────────────────────
            _SectionLabel(label: 'Instructions (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructionsCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. After meals, With water...',
                prefixIcon: Icon(Icons.info_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // ── Duration ─────────────────────────────────────────
            _SectionLabel(label: 'Duration'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.pillColors[_selectedColorIndex],
              ),
              child: Text(_isEditing ? 'Update Medicine' : 'Save & Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
