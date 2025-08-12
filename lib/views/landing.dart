import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gpt_web/constants/constants.dart';
import 'package:gpt_web/views/components/gradienttext.dart';
import 'package:gpt_web/views/home.dart';
import 'package:gpt_web/views/register.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  TextEditingController emailcon = TextEditingController();
  TextEditingController passwordcon = TextEditingController();

  final gptusers = FirebaseFirestore.instance.collection('gptusers');

  bool loading = false;
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundClr,
      body: loading == true
      ? SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) 
      : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GradientText(
            "GPT Web",
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
            ),
            gradient: LinearGradient(
              colors: [cyanC, torquiseT],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 1.0],
            ),
          ),
          SizedBox(
            height: 50,
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
              onChanged: (value) {
                setState(() {
                  
                });
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          emailcon.text.isEmpty && passwordcon.text.isEmpty
            ? SizedBox()
            : ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(torquiseT)
              ),
              child: Text('Login'),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                try {
                  var user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailcon.text, password: passwordcon.text);
                  if(user.user != null) {
                    if(context.mounted){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeView(user: emailcon.text),));
                    }
                  } else {
                    if(context.mounted) {

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email not verified")));
                    }
                    setState(() {
                      loading = false;
                    });
                  }
                } on FirebaseAuthException  catch (e) {
                  setState(() {
                    loading = false;
                  });
                  if (e.code == 'user-not-found') {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user found for that email.')));
                    }
                  } else if (e.code == 'wrong-password') {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong password provided for that user.')));
                    }
                  }
                }
              }
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(torquiseT)
              ),
              child: Text('Register', style: TextStyle(color: white),),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage(),));
              }
            )
        ],
      ),
    );
  }
}