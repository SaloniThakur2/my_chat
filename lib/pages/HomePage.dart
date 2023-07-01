import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/models/ChatRoomModel.dart';
import 'package:my_chat/models/FirebaseHelper.dart';
import 'package:my_chat/models/UIHelper.dart';
import 'package:my_chat/models/UserModel.dart';
import 'package:my_chat/pages/ChatRoomPage.dart';
import 'package:my_chat/pages/LoginPage.dart';
import 'package:my_chat/pages/SearchPage.dart';

class HomePage extends StatefulWidget { 
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({super.key, required this.userModel, required this.
  firebaseUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 116, 61, 126),
        shadowColor: Color.fromARGB(255, 106, 7, 123),
        centerTitle: true,
        title: Text("Chat App"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) {
                    return LoginPage();
                  }
                ),
              );
            },
            icon: Icon(Icons.exit_to_app),  
          
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms").where
            ("participants.${widget.userModel.uid}", isEqualTo: true).
            snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.active) {
                if(snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot = snapshot.data as 
                  QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap
                      (chatRoomSnapshot.docs[index].data() as Map<String,
                      dynamic>);

                      Map<String, dynamic> participants = chatRoomModel.participants!;

                      List<String> participantkeys = participants.keys.toList();
                      participantkeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById
                        (participantkeys[0]),
                        builder: (context, userData) {
                          if(userData.connectionState == ConnectionState.done) {
                            print("hello");

                            if(userData.data != null) {
                            UserModel targetUser = userData.data as 
                            UserModel;

                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                    chatroom: chatRoomModel,
                                    firebaseUser: widget.firebaseUser,
                                    userModel: widget.userModel,
                                    targetModel: targetUser,
                                  );
                                }),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 116, 61, 126),
                              backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                            ),
                            title: Text(targetUser.fullname.toString()),
                            subtitle: (chatRoomModel.lastMessage.
                            toString() != "") ? Text(chatRoomModel.
                            lastMessage.toString()) : 
                            Text("Say hi to your new friend!", style: TextStyle(
                              color: Color.fromARGB(255, 116, 61, 126),
                            ),), 
                          );
                        }
                        else {
                          return Container();
                        }
                      }
                      else {
                        return Container();
                          }
                        },
                      );
                    },                    
                  );
                }
                else if(snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                else {
                   return Center(
                    child: Text("No Chats"),
                   );
                }
              }
              else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),      
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 116, 61, 126),
        onPressed: () {
          
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
        ),
    );
  }
}