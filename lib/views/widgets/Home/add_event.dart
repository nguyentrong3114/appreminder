import 'package:flutter/material.dart';
import 'package:flutter_app/models/Calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEventWidget extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(CalendarEvent event) onAdd;

  const AddEventWidget({
    required this.selectedDate,
    required this.onAdd,
    super.key,
  });

  @override
  State<AddEventWidget> createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool allDay = false;
  bool reminder = false;
  bool alarmReminder = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsPadding: const EdgeInsets.only(right: 24, left: 24, bottom: 24, top: 8),
      title: Row(
        children: [
          const Icon(Icons.event, color: Colors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thêm sự kiện',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ngày: ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tên sự kiện *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.04),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nhập tên sự kiện' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _detailController,
                decoration: InputDecoration(
                  labelText: 'Chi tiết',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.notes),
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.04),
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Địa điểm',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on),
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.04),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: allDay
                          ? null
                          : () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() => _startTime = picked);
                              }
                            },
                      child: AbsorbPointer(
                        absorbing: allDay,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Bắt đầu',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.access_time),
                            filled: true,
                            fillColor: Colors.green.withOpacity(0.04),
                          ),
                          controller: TextEditingController(
                            text: allDay
                                ? 'Cả ngày'
                                : _startTime != null
                                    ? _startTime!.format(context)
                                    : '',
                          ),
                          enabled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: allDay
                          ? null
                          : () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() => _endTime = picked);
                              }
                            },
                      child: AbsorbPointer(
                        absorbing: allDay,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Kết thúc',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.access_time),
                            filled: true,
                            fillColor: Colors.green.withOpacity(0.04),
                          ),
                          controller: TextEditingController(
                            text: allDay
                                ? 'Cả ngày'
                                : _endTime != null
                                    ? _endTime!.format(context)
                                    : '',
                          ),
                          enabled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: allDay,
                onChanged: (v) => setState(() => allDay = v ?? false),
                title: const Text('Cả ngày'),
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: reminder,
                onChanged: (v) => setState(() => reminder = v ?? false),
                title: const Text('Nhắc nhở'),
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: alarmReminder,
                onChanged: (v) => setState(() => alarmReminder = v ?? false),
                title: const Text('Báo thức'),
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(fontSize: 16)),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(Icons.save),
            label: const Text('Lưu sự kiện'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final now = DateTime.now();
                final DateTime start = allDay
                    ? DateTime(widget.selectedDate.year, widget.selectedDate.month,
                        widget.selectedDate.day, 0, 0)
                    : DateTime(widget.selectedDate.year, widget.selectedDate.month,
                        widget.selectedDate.day, _startTime?.hour ?? now.hour, _startTime?.minute ?? now.minute);

                final DateTime end = allDay
                    ? DateTime(widget.selectedDate.year, widget.selectedDate.month,
                        widget.selectedDate.day, 23, 59)
                    : DateTime(widget.selectedDate.year, widget.selectedDate.month,
                        widget.selectedDate.day, _endTime?.hour ?? now.hour, _endTime?.minute ?? now.minute);

                final event = CalendarEvent(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.trim(),
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                  detail: _detailController.text.trim(),
                  location: _locationController.text.trim(),
                  startTime: start,
                  endTime: end,
                  allDay: allDay,
                  reminder: reminder,
                  alarmReminder: alarmReminder,
                  description: '',
                );

                widget.onAdd(event);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm sự kiện!')),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
