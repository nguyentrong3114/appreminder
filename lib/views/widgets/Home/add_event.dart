import 'package:flutter/material.dart';

class AddEventWidget extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventWidget({required this.selectedDate, super.key});

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
    return AlertDialog(
      title: const Text('Thêm sự kiện'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ngày: ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên sự kiện',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nhập tên sự kiện' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(
                  labelText: 'Chi tiết',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa điểm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 10),
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
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.access_time),
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
                  const SizedBox(width: 8),
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
                          decoration: const InputDecoration(
                            labelText: 'Kết thúc',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
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
              CheckboxListTile(
                value: allDay,
                onChanged: (v) => setState(() => allDay = v ?? false),
                title: const Text('Cả ngày'),
              ),
              CheckboxListTile(
                value: reminder,
                onChanged: (v) => setState(() => reminder = v ?? false),
                title: const Text('Nhắc nhở'),
              ),
              CheckboxListTile(
                value: alarmReminder,
                onChanged: (v) => setState(() => alarmReminder = v ?? false),
                title: const Text('Báo thức'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Xử lý lưu sự kiện ở đây
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm sự kiện!')),
              );
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
