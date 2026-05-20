import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ngibrit_in_cs/common/info.dart';
import 'package:ngibrit_in_cs/source/auth_source.dart';
import 'package:ngibrit_in_cs/widgets/button_primary.dart';
import 'package:ngibrit_in_cs/widgets/input.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final edtEmail = TextEditingController();
  final edtPassword = TextEditingController();

  signIn() {
    if (edtEmail.text == '') return Info.error('Email harus diisi!');
    if (edtPassword.text == '') return Info.error('Password harus diisi!');

    Info.showLoading(context, message: 'Loading..');

    AuthSource.signIn(edtEmail.text, edtPassword.text).then((message) {
      Info.hideLoading();
      
      // [PERBAIKAN 1] Typo diperbaiki menjadi 'success'
      if (message != 'success') return Info.error(message);

      Info.success('Sukses Masuk');
      Future.delayed(const Duration(milliseconds: 1500), () {
        // [PERBAIKAN 2] Rute diubah dari '/list-chat' menjadi '/main'
        Navigator.pushReplacementNamed(context, '/main');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        children: [
          const Gap(80),
          Image.asset('assets/logo_text.png', height: 36, width: 149),
          const Gap(70),
          const Text(
            'Masuk ke Akun',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xff070623),
            ),
          ),
          const Gap(30),
          const Text(
            'Alamat Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff070623),
            ),
          ),
          const Gap(12),
          Input(
            icon: 'assets/ic_email.png',
            hint: 'Masukkan email aktif',
            editingController: edtEmail,
          ),
          const Gap(20),
          const Text(
            'Kata Sandi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff070623),
            ),
          ),
          const Gap(12),
          Input(
            icon: 'assets/ic_key.png',
            hint: 'Masukkan kata sandi',
            editingController: edtPassword,
            obsecure: true,
          ),
          const Gap(30),
          ButtonPrimary(text: 'Masuk', onTap: signIn),
          const Gap(30),
        ],
      ),
    );
  }
}