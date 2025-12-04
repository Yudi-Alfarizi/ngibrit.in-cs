import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngibrit_in_cs/models/chat.dart';

class ChatSource {
  static Future<void> openChatRoom(String uid, String userName) async {
    final doc = await FirebaseFirestore.instance
        .collection('CS')
        .doc(uid)
        .get();

    if (doc.exists) {
      // [FIX] Jangan update 'name' jika room sudah ada.
      // Kita hanya update status notifikasi.
      await FirebaseFirestore.instance.collection('CS').doc(uid).update({
        'newFromCS': false,
      });
      return;
    }

    // First time chat room
    await FirebaseFirestore.instance.collection('CS').doc(uid).set({
      'roomId': uid,
      'name': userName, // Nama akun user (dikirim pertama kali user chat)
      'lastMessage': 'Welcome to Ngibrit.in',
      'newFromUser': false,
      'newFromCS': true,
    });

    await FirebaseFirestore.instance
        .collection('CS')
        .doc(uid)
        .collection('chats')
        .add({
          'roomId': uid,
          'message': 'Selamat Datang Ngibrit.in',
          'receiverId': uid,
          'senderId': 'cs',
          'bikeDetail': null,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
  // [FIX] Tambahkan method setRead
  static Future<void> setRead(String uid) async {
    await FirebaseFirestore.instance.collection('CS').doc(uid).update({
      'newFromUser': false, // Tandai pesan dari user sudah dibaca
    });
  }
  
  static Future<void> send(Chat chat, String uid) async {
    await FirebaseFirestore.instance.collection('CS').doc(uid).update({
      'lastMessage': chat.message,
      // [FIX] Update status agar naik ke atas list chat
      'newFromCS': true,
      'newFromUser': false,
    });

    await FirebaseFirestore.instance
        .collection('CS')
        .doc(uid)
        .collection('chats')
        .add({
          'roomId': chat.roomId,
          'message': chat.message,
          'receiverId': chat.receiverId,
          'senderId': chat.senderId,
          'bikeDetail': chat.bikeDetail,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
