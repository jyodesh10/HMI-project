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
  TextEditingController gendercon = TextEditingController();
  TextEditingController agecon = TextEditingController();
  TextEditingController occupationcon = TextEditingController();
  TextEditingController expcon = TextEditingController();
  bool loading = false;
  final gptusers = FirebaseFirestore.instance.collection('gptusers');
  List<String> gender = ["Male", "Female", "Other"];
  List<String> expwithllms = ["Yes", "No"];

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundClr,
      appBar: AppBar(
        backgroundColor: backgroundClr,
        elevation: 0,
      ),
      body: loading 
      ? Center(
        child: CircularProgressIndicator(),
      ) 
      : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:  deviceWidth < 700 ?  MediaQuery.of(context).size.width * 0.11 : MediaQuery.of(context).size.width * 0.35),
          child: Column(
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
              ListTile(
                title: const Text(
                  'Email (Student email if available)',
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
              SizedBox(
                height: 20,
              ),
              ListTile(
                title: const Text(
                  'Gender',
                  style: TextStyle(color: white, fontSize: 20),
                ),
                subtitle: DropdownButtonFormField(
                  style: TextStyle(color: white, fontSize: 16),
                  dropdownColor: backgroundClr,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: white, fontSize: 16),
                  ),
                  items: [
                    ...List.generate(gender.length, (index) => 
                    DropdownMenuItem(value: gender[index],child: Text(gender[index], style: TextStyle(color: white),),))
                  ],
                  onChanged: (value) {
                    setState(() {
                      gendercon.text = value.toString();
                    });
                  },
                )
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                title: const Text(
                  'Age',
                  style: TextStyle(color: white, fontSize: 20),
                ),
                subtitle: TextField(
                  controller: agecon,
                  style: TextStyle(color: white),
                  keyboardType: TextInputType.number,
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
                  'Occupation',
                  style: TextStyle(color: white, fontSize: 20),
                ),
                subtitle: TextField(
                  controller: occupationcon,
                  style: TextStyle(color: white),
                  decoration: InputDecoration(
                    hintText: "Eg: student, teacher, etc",
                    hintStyle: TextStyle(color: white.withAlpha(180), fontSize: 18)
                  ),
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
                  'Experience with LLMs(chatgpt, gemini, etc)',
                  style: TextStyle(color: white, fontSize: 20),
                ),
                subtitle: DropdownButtonFormField(
                  style: TextStyle(color: white, fontSize: 16),
                  dropdownColor: backgroundClr,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: white, fontSize: 16),
                  ),
                  items: [
                    ...List.generate(expwithllms.length, (index) => 
                    DropdownMenuItem(value: expwithllms[index],child: Text(expwithllms[index], style: TextStyle(color: white),),))
                  ],
                  onChanged: (value) {
                    setState(() {
                      expcon.text = value.toString();
                    });
                  },
                )
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
                  if(emailcon.text.isEmpty || passwordcon.text.isEmpty || gendercon.text.isEmpty || agecon.text.isEmpty || occupationcon.text.isEmpty || expcon.text.isEmpty) {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Empty Fields")));
                    }
                  } else {
                    try {
                      setState(() {
                        loading = true;
                      });
                      var cred =  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailcon.text, password: passwordcon.text);
                      if(cred.user != null) {
                        await gptusers.doc(FirebaseAuth.instance.currentUser?.uid).set({
                          'email': emailcon.text,
                          'password': passwordcon.text,
                          'gender': gendercon.text,
                          'age': agecon.text,
                          'occupation': occupationcon.text,
                          'experience': expcon.text,
                          "date": DateTime.now()
                        }).whenComplete(() {
                          setState(() {
                            loading = false;
                          });
                          if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully Registered")));
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
                }
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}