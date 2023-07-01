import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/models/FirebaseHelper.dart';
import 'package:my_chat/models/UserModel.dart';
import 'package:my_chat/pages/CompleteProfile.dart';
import 'package:my_chat/pages/HomePage.dart';
import 'package:my_chat/pages/LoginPage.dart';
import 'package:my_chat/pages/SignUpPage.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null) {

    UserModel? thisUserModel = await FirebaseHelper.getUserModelById
    (currentUser.uid);
    if(thisUserModel != null) {
      //runApp(MyApp());
    runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: 
    currentUser));
    }
    else {
      runApp(MyApp());
    }
  }
  else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.
  firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}