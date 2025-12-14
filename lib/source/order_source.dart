import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSource {
  static Stream<QuerySnapshot> getAllOrders() {
    return FirebaseFirestore.instance
        .collection('Orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<bool> confirmReturn(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Orders').doc(docId).update({
        'status': 'Selesai',
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
