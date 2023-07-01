import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/ChatRoomModel.dart';
import 'package:my_chat/models/MessageModel.dart';
import 'package:my_chat/models/UserModel.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetModel;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({Key? key, required this.targetModel, required this.
  chatroom, required this.userModel, required this.firebaseUser}) : super(key: key);
  
  
 
  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {

  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if(msg !="") {
      //snd msg
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false
      );

      FirebaseFirestore.instance.collection("chatrooms").doc(widget.
      chatroom.chatroomid).collection("messages").doc(newMessage.messageid).
      set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.
      chatroom.chatroomid).set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [

            CircleAvatar(
              backgroundColor: Color.fromARGB(255, 148, 102, 156),
              backgroundImage: NetworkImage(widget.targetModel.profilepic.toString()),
            ),

            SizedBox(width: 10,),

            Text(widget.targetModel.fullname.toString()),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 116, 61, 126),
       shadowColor: Color.fromARGB(255, 106, 7, 123),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
//This is where the chats will go
             Expanded(
               child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection
                  ("chatrooms").doc(widget.chatroom.chatroomid).collection
                  ("messages").orderBy("createdon", descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.active) {
                      if(snapshot.hasData) {
                        QuerySnapshot dataSnapshot = snapshot.data as 
                        QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.
                            fromMap(dataSnapshot.docs[index].data() as
                            Map<String, dynamic>);

                            return Row(
                              mainAxisAlignment: (currentMessage.sender == widget.userModel.uid) ?
                              MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 2
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (currentMessage.sender == widget.userModel.uid) ? Color.fromARGB(255, 99, 98, 98) :
                                    Color.fromARGB(255, 116, 61, 126),
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text(currentMessage.text.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ),
                              ],
                            );
                            
                          },
                        );
                      }
                      else if(snapshot.hasError) {
                         return Center(
                          child: Text("An error occured! Please check your internet connection"),
                        );
                      }
                      else {
                        return Center(
                          child: Text("Say hi to your new friend"),
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

                Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [

                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          cursorColor: Color.fromARGB(255, 116, 61, 126),
       
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter message",
                            
                          ),
                        ),
                        ),

                       IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 116, 61, 126),
                      ),
                    )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),     
    );
  }
}