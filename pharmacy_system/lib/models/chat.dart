// import 'package:cloud_firestore/cloud_firestore.dart';

// class Chat {
//   final String chatId;
//   final List<String> participants;
//   final String lastMessage;
//   final DateTime lastTimestamp;

//   Chat({
//     required this.chatId,
//     required this.participants,
//     required this.lastMessage,
//     required this.lastTimestamp,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'participants': participants,
//       'lastMessage': lastMessage,
//       'lastTimestamp': Timestamp.fromDate(lastTimestamp),
//     };
//   }

//   factory Chat.fromMap(String id, Map<String, dynamic> map) {
//     return Chat(
//       chatId: id,
//       participants: List<String>.from(map['participants'] ?? []),
//       lastMessage: map['lastMessage'] ?? '',
//       lastTimestamp:
//           (map['lastTimestamp'] as Timestamp).toDate(),
//     );
//   }
// }