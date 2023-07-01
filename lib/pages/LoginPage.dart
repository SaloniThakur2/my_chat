

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/models/UIHelper.dart';
import 'package:my_chat/models/UserModel.dart';
import 'package:my_chat/pages/HomePage.dart';
import 'package:my_chat/pages/SignUpPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues () {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? Credential;

    UIHelper.showLoadingDialog(context, "Logging In...");

    try {
      Credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      //Close the loading dialog
      Navigator.pop(context);

      // Show Alert Dialog
      UIHelper.showAlertDialog(context,"An error occured", ex.message.toString());
     
    }

    if(Credential != null) {
      String uid = Credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.
      collection('users').doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as 
      Map<String, dynamic>);

      //Go to HomePage
      print("Log In Successful!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(userModel: userModel, firebaseUser: Credential!.user!);
        }
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                        color: Color.fromARGB(255, 116, 61, 126),
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 116, 61, 126),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 116, 61, 126)),
                      ),
                      labelText: "Email Address",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 116, 61, 126),
                      ),
                      suffixIcon: Icon(
                        Icons.email,
                        color: Color.fromARGB(255, 116, 61, 126),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(   
                    controller: passwordController,               
                    obscureText: true,                   
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 116, 61, 126),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 116, 61, 126),),
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(
                         color: Color.fromARGB(255, 116, 61, 126),                      
                      ),
                      suffixIcon: Icon(
                      Icons.visibility,
                      color: Color.fromARGB(255, 116, 61, 126),
                    ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                       checkValues();                     
                    },
                  color: Color.fromARGB(255, 116, 61, 126),
                    child: Text("Log In"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SignUpPage();
                }));
              },
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Color.fromARGB(255, 116, 61, 126),
                  fontSize: 16),                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
