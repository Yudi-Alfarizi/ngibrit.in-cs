import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_session/d_session.dart';

class AuthSource {
  static Future<String> signIn(String email, String password) async {
    try {
      final csDoc = await FirebaseFirestore.instance.collection('admin').doc('cs').get();
      
      if (!csDoc.exists) return 'Data admin tidak ditemukan';
      
      final cs = csDoc.data()!;
      
      if (email == cs['email'] && password == cs['password']) {
        
        // [FIX BUG TIMESTAMP] Konversi semua Timestamp menjadi String
        Map<String, dynamic> safeData = Map.from(cs);
        safeData.forEach((key, value) {
          if (value is Timestamp) {
            safeData[key] = value.toDate().toIso8601String();
          }
        });

        await DSession.setUser(safeData);
        // [FIX TYPO] Sebelumnya 'scuccess'
        return 'success'; 
      }
      return 'Login Gagal: Email atau Password salah';
    } catch (e) {
      return 'Terjadi kesalahan sistem: $e';
    }
  }
}