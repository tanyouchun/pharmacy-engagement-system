import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/reminder_viewmodel.dart';
import '../models/reminder.dart';

class CreateReminderView extends StatefulWidget {
  final Reminder? reminder;
  const CreateReminderView({super.key, this.reminder});

  @override
  State<CreateReminderView> createState() => _CreateReminderViewState();
}

class _CreateReminderViewState extends State<CreateReminderView> {
  TimeOfDay? selectedTime;
  String frequency = "Once daily";
  String medicationName = "";

  @override
  void initState() {
    super.initState();

    if (widget.reminder != null) {
      medicationName = widget.reminder!.medicationName;
      frequency = widget.reminder!.frequency;

      selectedTime = TimeOfDay(
        hour: widget.reminder!.scheduleTime.hour,
        minute: widget.reminder!.scheduleTime.minute,
      );
    }
  }

  final vm = ReminderViewModel();

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> _save() async {
    if (selectedTime == null || medicationName.isEmpty) return;

    final vm = Provider.of<ReminderViewModel>(context, listen: false);

    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (widget.reminder == null) {
      /// CREATE
      await vm.createReminder(
        Reminder(
          reminderId: "",
          userId: vm.userId,
          prescriptionId: "",
          medicationName: medicationName,
          scheduleTime: dateTime,
          frequency: frequency,
        ),
      );
    } else {
      /// UPDATE
      await vm.updateReminder(
        widget.reminder!.copyWith(
          medicationName: medicationName,
          time: dateTime,
          frequency: frequency,
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Reminder")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Medication Name"),
              onChanged: (v) => medicationName = v,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _pickTime,
              child: const Text("Pick Time"),
            ),

            const SizedBox(height: 10),

            DropdownButton<String>(
              value: frequency,
              items:
                  ["Once daily", "Twice daily", "Thrice daily", "Every 6 hours", "Every 8 hours", "Every 12 hours", "Every 24 hours"]
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
              onChanged: (v) => setState(() => frequency = v!),
            ),

            const Spacer(),

            ElevatedButton(onPressed: _save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
