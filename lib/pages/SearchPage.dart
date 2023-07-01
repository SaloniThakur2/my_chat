import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/ChatRoomModel.dart';
import 'package:my_chat/models/UserModel.dart';
import 'package:my_chat/pages/ChatRoomPage.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({super.key, required this.userModel, required this.firebaseUser});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getchatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection
    ("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: 
    true).where("participants.${targetUser.uid}", isEqualTo: true).get(); 

    if(snapshot.docs.length > 0) {
      // Fetch the existing one
      var docdata = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docdata as Map<String, dynamic>);

      chatRoom = existingChatroom;
    }
    else {
     // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance.collection("chatrooms").doc
      (newChatroom.chatroomid).set(newChatroom.toMap());

      chatRoom = newChatroom; 

      print("new chatroom created");
    } 

    return chatRoom;
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Color.fromARGB(255, 116, 61, 126),
       shadowColor: Color.fromARGB(255, 106, 7, 123),
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(

            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [

              TextField(
                cursorColor: Color.fromARGB(255, 116, 61, 126),
                controller: searchController,
                decoration: InputDecoration(
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

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  setState(() {
                    
                  });
                },
                color: Color.fromARGB(255, 116, 61, 126),
                child: Text("Search"),
              ),

              SizedBox(height: 20,),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").where
                ("email", isEqualTo: searchController.text).where("email",
                isNotEqualTo: widget.userModel.email).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.active) {
                    if(snapshot.hasData) {
                      QuerySnapshot dataSnapshot = snapshot.data as
                      QuerySnapshot;

                      if(dataSnapshot.docs.length > 0) {
                         Map<String, dynamic> userMap = dataSnapshot.docs[0].
                      data() as Map<String, dynamic>;

                      UserModel searchedUser = UserModel.fromMap(userMap);

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatRoomModel = await 
                          getchatroomModel(searchedUser);

                          if(chatRoomModel != null) {
                             Navigator.pop(context);
                             Navigator.push(context, MaterialPageRoute(
                               builder: (context) {
                                 return ChatRoomPage(
                                   targetModel: searchedUser,
                                   userModel: widget.userModel,
                                   firebaseUser: widget.firebaseUser,
                                   chatroom: chatRoomModel,
                                  );
                                }
                              ));
                            }               
                        },
                        leading: CircleAvatar(
                        backgroundColor:Color.fromARGB(255, 148, 102, 156),
                        backgroundImage: NetworkImage(searchedUser.profilepic!),
                        foregroundColor: Colors.grey[500],
                        ),
   
                        title: Text(searchedUser.fullname!),
                        subtitle: Text(searchedUser.email!),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      );
                      }
                      else {
                         return Text("No results found!");
                      }
                     
                    }
                    else if(snapshot.hasError) {
                      return Text("An error occured!");
                    }
                    else {
                      return Text("No results found!");
                    }
                  }
                  else {
                    return CircularProgressIndicator();
                  }
                }
              ),
            ],
          ),
        )
      ),
    );
  }
}