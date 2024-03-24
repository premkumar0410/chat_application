import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messagecontoller = TextEditingController();

  @override
  void dispose() {
    _messagecontoller.dispose();
    super.dispose();
  }

  void _onsubmiting() async {
    final enteredmessage = _messagecontoller.text;
    if (enteredmessage.trim().isEmpty) {
      return;
    }

    _messagecontoller.clear();
    final user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance
        .collection('user-data')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredmessage,
      'createAt': Timestamp.now(),
      'userid': user.uid,
      'username': userdata.data()!['username'],
      'userimage': userdata.data()!['profilepic']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 8),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _messagecontoller,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                labelStyle: TextStyle(color: Color.fromARGB(255, 1, 57, 79)),
                label: Text('Message here...')),
          ),
        ),
        IconButton(
          onPressed: _onsubmiting,
          icon: const Icon(Icons.send),
          color: Theme.of(context).colorScheme.primary,
        )
      ]),
    );
  }
}
