import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/alarm_service.dart';
import 'package:flutter_app/services/calendar_service.dart';
import 'package:flutter_app/provider/setting_provider.dart';

class AddEventWidget extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(CalendarEvent event) onAdd;
  final CalendarEvent? event; // thêm vào AddEventWidget

  const AddEventWidget({
    required this.selectedDate,
    required this.onAdd,
    this.event, // thêm dòng này
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
  int repeatIntervalHours = 1; // mặc định 1 giờ

  @override
  void initState() {
    super.initState();
    // Nếu có sự kiện được truyền vào, điền thông tin vào các trường
    if (widget.event != null) {
      final event = widget.event!;
      _titleController.text = event.title;
      _detailController.text = event.detail;
      _locationController.text = event.location;
      allDay = event.allDay;
      reminder = event.reminder;
      alarmReminder = event.alarmReminder;
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      // Nếu sự kiện là cả ngày, đặt giờ bắt đầu và kết thúc là 00:00 và 23:59
      if (allDay) {
        _startTime = const TimeOfDay(hour: 0, minute: 0);
        _endTime = const TimeOfDay(hour: 23, minute: 59);
      }
    }
  }

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
              if (allDay && alarmReminder)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Text('Báo thức mỗi:'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: repeatIntervalHours,
                        items: [1, 2, 4, 6, 8, 12].map((h) => DropdownMenuItem(
                          value: h,
                          child: Text('$h giờ'),
                        )).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => repeatIntervalHours = v);
                        },
                      ),
                    ],
                  ),
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final now = DateTime.now();
                final DateTime start = allDay
                    ? DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 0, 0)
                    : DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, _startTime?.hour ?? now.hour, _startTime?.minute ?? now.minute);

                final DateTime end = allDay
                    ? DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 23, 59)
                    : DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, _endTime?.hour ?? now.hour, _endTime?.minute ?? now.minute);

                // Kiểm tra giờ kết thúc phải lớn hơn giờ bắt đầu
                if (!allDay && (end.isBefore(start) || end.isAtSameMomentAs(start))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Giờ kết thúc phải lớn hơn giờ bắt đầu!')),
                  );
                  return;
                }

                final eventId = widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

                final event = CalendarEvent(
                  id: eventId,
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

                if (widget.event == null) {
                  await CalendarService().addEvent(event);
                } else {
                  await CalendarService().updateEvent(eventId, event);
                }

                // Lấy âm thanh từ SettingProvider
                final alarmSound = context.read<SettingProvider>().alarmSound;
                final notiSound = context.read<SettingProvider>().notificationSound;

                final int alarmId = (int.tryParse(eventId) ?? DateTime.now().millisecondsSinceEpoch) % 2147483647;

                // 1. Đặt notification trước giờ bắt đầu 10 phút (nếu reminder)
                if (reminder) {
                  final DateTime notiTime = start.subtract(const Duration(minutes: 10));
                  if (notiTime.isAfter(DateTime.now())) {
                    await AlarmService.showNotification(
                      id: alarmId + 100000, // id khác với alarm
                      title: 'Sắp đến sự kiện',
                      body: event.title,
                      sound: notiSound,
                      scheduledTime: notiTime,
                    );
                  }
                }

                // 2. Đúng giờ bắt đầu: notification
                if (reminder) {
                  if (start.isAfter(DateTime.now())) {
                    await AlarmService.showNotification(
                      id: alarmId + 200000,
                      title: 'Đến giờ sự kiện',
                      body: event.title,
                      sound: notiSound,
                      scheduledTime: start,
                    );
                  }
                }

                // 3. Đúng giờ bắt đầu: báo thức (nếu tick alarmReminder)
                if (alarmReminder && start.isAfter(DateTime.now())) {
                  await AlarmService.scheduleAlarm(
                    id: alarmId,
                    title: event.title,
                    body: event.detail.isNotEmpty ? event.detail : 'Đã đến giờ sự kiện!',
                    scheduledTime: start,
                    sound: alarmSound,
                  );
                }

                if (allDay && alarmReminder) {
                  DateTime current = DateTime(start.year, start.month, start.day, 0, 0);
                  final DateTime endOfDay = DateTime(start.year, start.month, start.day, 23, 59);

                  int repeatIndex = 0;
                  while (current.isBefore(endOfDay)) {
                    if (current.isAfter(DateTime.now())) {
                      // Đặt báo thức/notification
                    }
                    current = current.add(Duration(hours: repeatIntervalHours));
                    repeatIndex++;
                  }
                }

                widget.onAdd(event);
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(widget.event == null ? 'Thành công' : 'Cập nhật thành công'),
                    content: Text(widget.event == null
                        ? 'Đã thêm sự kiện!'
                        : 'Đã cập nhật sự kiện!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
