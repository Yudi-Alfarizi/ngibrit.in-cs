import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ngibrit_in_cs/widgets/button_primary.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Gap(70),
          Image.asset('assets/logo_text.png', height: 36, width: 149),
          const Gap(10),
          const Text(
            'We serve, they ride.',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xff070623),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(-50, 0), 
              child: Image.asset('assets/splash_vespa.png'),
            )),
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              textAlign: TextAlign.center,
              'Tim CS siap bantu kapan pun — biar pelanggan tetap enjoy di setiap perjalanan.',
              style: TextStyle(
                height: 1.7,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff070623),
              ),
            ),
          ),
          const Gap(30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ButtonPrimary(text: 'Let’s Serve!', onTap: () {
              Navigator.pushReplacementNamed(context, '/signin');
            }),
          ),
          const Gap(50),
        ],
      ),
    );
  }
}
