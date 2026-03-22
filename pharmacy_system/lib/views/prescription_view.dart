// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../viewmodels/prescription_viewmodel.dart';
// import '../models/prescription.dart';

// class PrescriptionPage extends StatefulWidget {
//   const PrescriptionPage({super.key});

//   @override
//   State<PrescriptionPage> createState() => _PrescriptionPageState();
// }

// class _PrescriptionPageState extends State<PrescriptionPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       Provider.of<PrescriptionViewModel>(context, listen: false)
//           .loadPrescriptions();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = Provider.of<PrescriptionViewModel>(context);

//     return Scaffold(
//       body: vm.isLoadingPrescription
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: vm.prescriptions.length,
//               itemBuilder: (context, index) {
//                 final p = vm.prescriptions[index];

//                 return Card(
//                   child: ListTile(
//                     leading: const Icon(Icons.medication),
//                     title: Text(p.name),
//                     subtitle: Text("Added: ${p.date}"),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             _showEditDialog(context, p);
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () {
//                             vm.deletePrescription(p.id);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),

//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           _showAddDialog(context);
//         },
//         label: const Text("Add new prescription"),
//         icon: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// void _showAddDialog(BuildContext context) {
//   final nameController = TextEditingController();
//   final notesController = TextEditingController();

//   final vm = Provider.of<PrescriptionViewModel>(context, listen: false);

//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text("Add Prescription"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
//           TextField(controller: notesController, decoration: const InputDecoration(labelText: "Notes")),
//         ],
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//         TextButton(
//           onPressed: () async {
//             await vm.addPrescription(
//               nameController.text,
//               notesController.text,
//             );
//             Navigator.pop(context);
//           },
//           child: const Text("Save"),
//         ),
//       ],
//     ),
//   );
// }

// void _showEditDialog(BuildContext context, Prescription p) {
//   final nameController = TextEditingController(text: p.name);
//   final notesController = TextEditingController(text: p.notes);

//   final vm = Provider.of<PrescriptionViewModel>(context, listen: false);

//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text("Edit Prescription"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(controller: nameController),
//           TextField(controller: notesController),
//         ],
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//         TextButton(
//           onPressed: () async {
//             await vm.updatePrescription(
//               p.id,
//               nameController.text,
//               notesController.text,
//             );
//             Navigator.pop(context);
//           },
//           child: const Text("Update"),
//         ),
//       ],
//     ),
//   );
// }