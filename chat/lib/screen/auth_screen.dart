import 'dart:io';

import 'package:chat/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _islogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedimage;
  var _authentication = false;
  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_islogin && _selectedimage == null) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            'Check Whether You Filled The Form Correctly..\n BUMDAMAVANA',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'ok',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ))
          ],
        ),
      );
    }
    _form.currentState!.save();
    try {
      setState(() {
        _authentication = true;
      });
      if (_islogin) {
        // ignore: unused_local_variable
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        // ignore: unused_local_variable
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final stoargeref = FirebaseStorage.instance
            .ref()
            .child('user-profile')
            .child('${userCredential.user!.uid}.jpg');

        await stoargeref.putFile(_selectedimage!);
        final imageurl = await stoargeref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('user-data')
            .doc(userCredential.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'profilepic': imageurl
        });

        setState(() {
          _authentication = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Faileds')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 100, bottom: 20, left: 100, right: 100),
                    width: 200,
                    child: Visibility(
                      visible: !_authentication,
                      child: Image.asset('assets/images/comments.png'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Visibility(
                        visible: _authentication,
                        child: Icon(
                          Icons.verified,
                          size: 80,
                        )),
                  )
                ],
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                      key: _form,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_authentication)
                              if (!_islogin)
                                Center(
                                    child: Text('PROFILE',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w700))),
                            const SizedBox(height: 10),
                            if (!_islogin)
                              UserImagePicker(
                                onPickedimage: (pickedimage) {
                                  _selectedimage = pickedimage;
                                },
                              ),
                            if (!_islogin)
                              TextFormField(
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 2 ||
                                      value.isEmpty) {
                                    return 'Check You\'r Username.';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                onSaved: (value) {
                                  _enteredUsername = value!;
                                },
                              ),
                            TextFormField(
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    !value.trim().contains('@')) {
                                  return 'Check You\'r E-mail account.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                              decoration: const InputDecoration(
                                label: Text(
                                  'E mail',
                                ),
                              ),
                            ),
                            TextFormField(
                              autocorrect: false,
                              obscureText: true,
                              validator: (value) {
                                if (value!.trim().length < 6) {
                                  return 'Password must be 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                              decoration: const InputDecoration(
                                label: Text(
                                  'Password',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_authentication == true)
                              const CircularProgressIndicator(),
                            if (!_authentication)
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  onPressed: _submit,
                                  child: Text(_islogin ? 'login' : 'sign-up')),
                            if (!_authentication)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _islogin = !_islogin;
                                    });
                                  },
                                  child: Text(_islogin
                                      ? 'create an  account'
                                      : 'Alredy have an account.'))
                          ],
                        ),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
