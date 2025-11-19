import 'package:d_session/d_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngibrit_in_cs/page/chatting_page.dart';
import 'package:ngibrit_in_cs/page/list_chat_page.dart';
import 'package:ngibrit_in_cs/page/signin_page.dart';
import 'package:ngibrit_in_cs/page/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffEFEFF0),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: FutureBuilder(
        future: DSession.getUser(),
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if(snapshot.data==null) return const SplashScreen();
          return const ListChatPage();
        },
      ),
       routes: {
        '/list-chat': (context) => const ListChatPage(),
        '/signin': (context) => const SigninPage(),
        '/chatting': (context) {
          Map data = ModalRoute.of(context)!.settings.arguments as Map;
          String uid = data['uid'];
          String userName = data['userName'];
          return ChattingPage(uid: uid, userName: userName);
        },
      },
    );
  }
}
