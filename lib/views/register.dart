import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gpt_web/constants/constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailcon = TextEditingController();
  TextEditingController passwordcon = TextEditingController();
  bool loading = false;
  final gptusers = FirebaseFirestore.instance.collection('gptusers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundClr,

      body: loading 
      ? Center(
        child: CircularProgressIndicator(),
      ) 
      : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            child: Text("Register", style: TextStyle(color: white, fontSize: 30),),
          ),
          SizedBox(
            height: 20,
          ),
          const Text(
            'Email',
            style: TextStyle(color: white, fontSize: 20),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.4),
            child: TextField(
              controller: emailcon,
              style: TextStyle(color: white),
              onChanged: (value) {
                setState(() {
                  
                });
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          const Text(
            'Password',
            style: TextStyle(color: white, fontSize: 20),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.4),
            child: TextField(
              controller: passwordcon,
              style: TextStyle(color: white),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  
                });
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(torquiseT)
            ),
            child: Text('Register', style: TextStyle(color: white),),
            onPressed: () async {
              try {
                loading = true;
                var cred =  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailcon.text, password: passwordcon.text);
                if(cred.user != null) {
                  await gptusers.doc(FirebaseAuth.instance.currentUser?.uid).set({
                    'email': emailcon.text,
                    'password': passwordcon.text,
                  }).whenComplete(() {
                    setState(() {
                      loading = false;
                    });
                    if(context.mounted){
                      Navigator.pop(context);
                    }
                  });
                }
              } on FirebaseException catch (e) {
                setState(() {
                  loading = false;
                });
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
                }
              }
            }
          )
        ],
      ),
    );
  }
}