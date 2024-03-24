import 'package:chat/widgets/chat_message_screen.dart';

import 'package:chat/widgets/new_messages.dart';
import 'package:chat/widgets/setting.dart';

import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat App'),
          backgroundColor: Color.fromARGB(255, 221, 237, 249),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Setting(),
                      ));
                },
                icon: Icon(
                  Icons.settings,
                  size: 30,
                )),
          ],
        ),
        body: const Column(
          children: [Expanded(child: ChatMessage()), NewMessage()],
        ));
  }
}
