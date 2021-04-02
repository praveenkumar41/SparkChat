import 'package:flutter/material.dart';
import 'package:sparkchat/screens/All_users.dart';
import 'package:sparkchat/screens/Chat_Screen.dart';
import 'package:sparkchat/screens/Homepage.dart';
import 'package:sparkchat/screens/Profile_Page.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/MobileAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MaterialApp(
        theme: new ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id:(context) =>WelcomeScreen(),
          homepage.id:(context) =>homepage(),
          mobileauth.id:(context) =>mobileauth(),
          chatscreen.id:(context) =>chatscreen(),
          LoginScreen.id:(context) =>LoginScreen(),
          RegistrationScreen.id:(context) =>RegistrationScreen(),
          allusers.id:(context) =>allusers(),
          profilepage.id:(context) =>profilepage(),
        },
      ));
}
