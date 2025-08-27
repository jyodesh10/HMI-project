import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gpt_web/constants/constants.dart';
import 'package:gpt_web/views/components/gradienttext.dart';
import 'package:gpt_web/views/home.dart';
import 'package:gpt_web/views/register.dart';
import 'package:url_launcher/url_launcher.dart';
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

  final Uri _url = Uri.parse('https://github.com/jyodesh10/HMI-project');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
 

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundClr,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {
            _launchUrl();
          }, icon: Icon(FontAwesomeIcons.github, color: white, size: 22,)),
          // IconButton(onPressed: () {
          //   _launchUrl();
          // }, icon: Icon(FontAwesomeIcons.circleInfo, color: white, size: 22,)),
          SizedBox(width: 20,)
        ],
      ),
      body: loading == true
      ? SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) 
      : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 35,
            ),
            GradientText(
              "HMI Project",
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
              height: 10,
            ),
            Text('''Topic : How do prompt revision and assisted feedback mechanisms influence \nin improving output across diverse LLM-supported tasks?''', style: TextStyle(color: white.withAlpha(200)), textAlign: TextAlign.center,),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:  deviceWidth < 700 ?  MediaQuery.of(context).size.width * 0.11 : MediaQuery.of(context).size.width * 0.35),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Email',
                      style: TextStyle(color: white, fontSize: 20),
                    ),
                    subtitle: TextField(
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
                  ListTile(
                    title: const Text(
                      'Password',
                      style: TextStyle(color: white, fontSize: 20),
                    ),
                    subtitle: TextField(
                      controller: passwordcon,
                      style: TextStyle(color: white),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          
                        });
                      },
                    ),
                  ),
                ],
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
              Text('Don\'t have an account?', style: TextStyle(color: white),),
              SizedBox(
                height: 6,
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
      ),
    );
  }
}