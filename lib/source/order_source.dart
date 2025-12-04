import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSource {
  // 1. Ambil Semua Order (Untuk CS List)
  // Bisa difilter berdasarkan status jika diperlukan nanti
  static Stream<QuerySnapshot> getAllOrders() {
    return FirebaseFirestore.instance
        .collection('Orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 2. CS Konfirmasi Pengembalian Motor (Berlangsung -> Selesai)
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
