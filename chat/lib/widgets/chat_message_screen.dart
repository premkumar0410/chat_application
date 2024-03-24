import 'package:chat/widgets/message_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    final autheticateduser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createAt',
            descending: true,
          )
          .snapshots(),
      builder: (contctxxt, chatsnapshot) {
        if (chatsnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatsnapshot.hasData || chatsnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('NO Messages founded.'),
          );
        }
        if (chatsnapshot.hasError) {
          return const Center(
            child: Text('Something Went Wrong'),
          );
        }
        final loadedmessages = chatsnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            reverse: true,
            itemCount: loadedmessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedmessages[index].data();

              final nextchatMessage = index + 1 < loadedmessages.length
                  ? loadedmessages[index + 1].data()
                  : null;

              final currentmessageUserid = chatMessage['userid'];
              final nextmessageUserid =
                  nextchatMessage != null ? nextchatMessage['userid'] : null;

              final nextuserisSame = nextmessageUserid == currentmessageUserid;

              if (nextuserisSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: autheticateduser.uid == currentmessageUserid);
              } else {
                return MessageBubble.first(
                  userImage: chatMessage['userimage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: autheticateduser.uid == currentmessageUserid,
                );
              }
            });
      },
    );
  }
}
