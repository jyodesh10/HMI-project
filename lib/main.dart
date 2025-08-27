import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gpt_web/views/landing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDp7XgIWbG6yeOeXdqjTz_ZII7wJDDZSBo", 
      appId: "1:157775836903:web:1bef0aa8906c8d6b21d442",
      messagingSenderId: "157775836903", 
      projectId: "auth-3725d"
    )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HMI PROJECT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LandingView() 
      // HomeView(),
    );
  }
}
