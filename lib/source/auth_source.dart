import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_session/d_session.dart';

class AuthSource{
  static Future<String> signIn(String email,String password) async {
    final csDoc =
        await FirebaseFirestore.instance.collection('admin').doc('cs').get();
    final cs = csDoc.data()!;
    if(email == cs['email'] && password == cs['password']) {
      DSession.setUser(cs);
      return 'scuccess';
    }
    return 'Login Gagal';

  }
}