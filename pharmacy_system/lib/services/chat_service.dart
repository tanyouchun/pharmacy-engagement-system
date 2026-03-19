import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrGetChat(String pharmacistId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final chats = _firestore.collection('chats');

    final query = await chats
        .where('participants', arrayContains: user.uid)
        .get();

    for (var doc in query.docs) {
      List participants = doc['participants'];
      if (participants.contains(pharmacistId)) {
        return doc.id; // existing chat
      }
    }

    // create new chat
    final newChat = await chats.add({
      'participants': [user.uid, pharmacistId],
      'lastMessage': '',
      'lastTimestamp': Timestamp.now(),
    });

    return newChat.id;
  }
}