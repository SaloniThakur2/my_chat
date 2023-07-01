import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_chat/models/UserModel.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseHelper {

  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection
    ("users").doc(uid).get();

    if(docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }
}