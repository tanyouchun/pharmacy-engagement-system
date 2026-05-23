// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../viewmodels/reminder_viewmodel.dart';
// import '../../models/reminder.dart';

// class CreateReminderView extends StatefulWidget {
//   final Reminder? reminder;

//   const CreateReminderView({super.key, this.reminder});

//   @override
//   State<CreateReminderView> createState() => _CreateReminderViewState();
// }

// class _CreateReminderViewState extends State<CreateReminderView> {
//   TimeOfDay? selectedTime;
//   String frequency = "Once daily";
//   String medicationName = "";

//   final List<String> frequencies = [
//     "Once daily",
//     "Twice daily",
//     "Thrice daily",
//     "Every 6 hours",
//     "Every 8 hours",
//     "Every 12 hours",
//     "Every 24 hours",
//   ];

//   @override
//   void initState() {
//     super.initState();

//     if (widget.reminder != null) {
//       medicationName = widget.reminder!.medicationName;
//       frequency = widget.reminder!.frequency;

//       selectedTime = TimeOfDay(
//         hour: widget.reminder!.scheduleTime.hour,
//         minute: widget.reminder!.scheduleTime.minute,
//       );
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: selectedTime ?? TimeOfDay.now(),
//     );

//     if (time != null) {
//       setState(() => selectedTime = time);
//     }
//   }

//   Future<void> _save() async {
//     if (selectedTime == null || medicationName.isEmpty) return;

//     final reminderViewModel =
//         Provider.of<ReminderViewModel>(context, listen: false);

//     final now = DateTime.now();

//     final dateTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       selectedTime!.hour,
//       selectedTime!.minute,
//     );

//     if (widget.reminder == null) {
//       await reminderViewModel.createReminder(
//         Reminder(
//           reminderId: "",
//           userId: reminderViewModel.userId,
//           prescriptionId: "",
//           medicationName: medicationName,
//           scheduleTime: dateTime,
//           frequency: frequency,
//         ),
//       );
//     } else {
//       await reminderViewModel.updateReminder(
//         widget.reminder!.copyWith(
//           medicationName: medicationName,
//           time: dateTime,
//           frequency: frequency,
//         ),
//       );
//     }

//     if (!mounted) return;
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.reminder != null;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         centerTitle: true,
//         title: Text(
//           isEditing ? "Edit Reminder" : "Create Reminder",
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             const Text(
//               "Medication Reminder",
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               "Set up reminders for your medication schedule.",
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 15,
//               ),
//             ),

//             const SizedBox(height: 30),

//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),

//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   /// Medication Name
//                   const Text(
//                     "Medication Name",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   TextFormField(
//                     initialValue: medicationName,
//                     decoration: InputDecoration(
//                       hintText: "Enter medication name",
//                       prefixIcon: const Icon(Icons.medication_outlined),
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (v) => medicationName = v,
//                   ),

//                   const SizedBox(height: 25),

//                   const Text(
//                     "Reminder Time",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   InkWell(
//                     onTap: _pickTime,
//                     borderRadius: BorderRadius.circular(16),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 18,
//                         vertical: 18,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(16),
//                       ),

//                       child: Row(
//                         children: [
//                           const Icon(Icons.access_time_rounded),

//                           const SizedBox(width: 12),

//                           Expanded(
//                             child: Text(
//                               selectedTime == null
//                                   ? "Select reminder time"
//                                   : selectedTime!.format(context),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),

//                           const Icon(Icons.arrow_forward_ios_rounded, size: 18),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 25),

//                   /// Frequency
//                   const Text(
//                     "Frequency",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: frequency,
//                         isExpanded: true,
//                         icon: const Icon(Icons.keyboard_arrow_down_rounded),
//                         items: frequencies
//                             .map(
//                               (f) => DropdownMenuItem(
//                                 value: f,
//                                 child: Text(f),
//                               ),
//                             )
//                             .toList(),
//                         onChanged: (v) {
//                           setState(() {
//                             frequency = v!;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 40),

//             SizedBox(
//               width: double.infinity,
//               height: 58,
//               child: ElevatedButton(
//                 onPressed: _save,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                 ),
//                 child: Text(
//                   isEditing ? "Update Reminder" : "Save Reminder",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }