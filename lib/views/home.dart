import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:gpt_web/api/api_repo.dart';
import 'package:gpt_web/constants/constants.dart';
import 'package:gpt_web/views/components/gradienttext.dart';
import 'package:gpt_web/views/components/richtext_formatter.dart';

import 'landing.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.user});
  final String user;
  @override
  State<HomeView> createState() => _HomeViewState();
}

// Define Intents for our actions
class SubmitIntent extends Intent {}

class NewlineIntent extends Intent {}

class _HomeViewState extends State<HomeView> {
  TextEditingController prompt = TextEditingController();
  late ScrollController scrollController;
  bool loading = false;
  String output = '';
  List<Map> history = [];
  String currentUser = "";

  runPrompt(val) async {
    setState(() {
      loading = true;
    });
    output = await ApiRepo().geminiApiPost(val);
    String historyId = FirebaseFirestore.instance.collection("gptusers").doc(currentUser).collection("history").doc().id;
    history.add({'id': historyId, 'prompt': val, 'output': output, 'rating':0.0});
    setState(() {
      loading = false;
    });
    prompt.clear();
    FirebaseFirestore.instance.collection("gptusers").doc(currentUser).collection("history").doc(historyId).set({
      "id": historyId,
      "prompt": history.last['prompt'],
      "output": history.last['output'],
      "rating": 0.0,
    });
    Future.delayed(Duration(milliseconds: 2), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  clearOutput() {
    output = '';
    history.clear();
    prompt.clear();
    setState(() {});
  }

  // Action handler for submitting the prompt
  void _handleSubmitIntent() {
    if (prompt.text.trim().isNotEmpty) {
      runPrompt(prompt.text);
      // Optionally, you might want to clear the prompt after submission:
      // prompt.clear();
    }
  }

  // Action handler for inserting a newline
  void _handleNewlineIntent() {
    final currentText = prompt.text;
    final currentSelection = prompt.selection;
    final newText =
        '${currentText.substring(0, currentSelection.start)}\n${currentText.substring(currentSelection.end)}';
    prompt.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: currentSelection.start + 1),
    );
  }

  late final Map<ShortcutActivator, Intent> _shortcuts;
  late final Map<Type, Action<Intent>> _actions;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid.toString();
    scrollController = ScrollController();
    // prompt.addListener(() {
    //   setState(() {});
    // }); 
    _shortcuts = <ShortcutActivator, Intent>{
      LogicalKeySet(LogicalKeyboardKey.enter): SubmitIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter):
          NewlineIntent(),
    };
    _actions = <Type, Action<Intent>>{
      SubmitIntent: CallbackAction<SubmitIntent>(
        onInvoke: (intent) => _handleSubmitIntent(),
      ),
      NewlineIntent: CallbackAction<NewlineIntent>(
        onInvoke: (intent) => _handleNewlineIntent(),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundClr,
      body: Row(
        children: [
          sideBar(),
          Expanded(
            flex: 8,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      loading
                          ? SizedBox(
                              height: deviceHeight * 0.7,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Expanded(
                              flex: history.isNotEmpty? 3 : 1,
                              child: history.isNotEmpty 
                                  ? SingleChildScrollView(
                                    controller: scrollController,
                                    child: Container(
                                        margin: EdgeInsets.only(
                                          top: 70,
                                          right: deviceWidth * 0.1,
                                          left: deviceWidth * 0.1,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: List.generate(history.length, (index) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    // margin: EdgeInsets.only(left: deviceWidth * 0.4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.purple,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(history[index]['prompt'], style: TextStyle(color: white),),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                buildFormattedText(history[index]['output']),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text("Rate this response", style: TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.w100),),
                                                      StarRating(
                                                        rating: double.parse(history[index]['rating'].toString()),
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        size: 20,
                                                        starCount: 5,
                                                        allowHalfRating: false,
                                                        onRatingChanged: (rating) {
                                                          FirebaseFirestore.instance.collection("gptusers").doc(currentUser).collection("history").doc(history[index]['id']).update({
                                                            "rating": rating
                                                          }).whenComplete(() {
                                                            setState(() {
                                                              history[index]['rating'] = rating;
                                                            });
                                                          },);
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                ),
                                                SizedBox(
                                                  height: 50,
                                                ),
                                              ],
                                            );
                                          },),
                                        ),
                                      ),
                                  )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GradientText(
                                          "Hello, ${widget.user}",
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
                                        SizedBox(height: 20),
                                        Text(
                                          "How can we help you today?",
                                          style: TextStyle(
                                            color: white.withValues(alpha: 0.8),
                                            fontWeight: FontWeight.w100,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                      // textfield
                      output != ""
                        ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: deviceWidth*.1 ),
                          child: ExpansionTile(
                            title: Text("Suggestions", style: TextStyle(color: white, fontSize: 15),),
                            iconColor: white,
                            collapsedIconColor: white,
                            shape: Border(),
                            expandedCrossAxisAlignment: CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              Wrap(
                                runSpacing: 10,
                                spacing: 10,
                                runAlignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: backgroundClrLight
                                    ),
                                    child: Text("Lorem Ipsom", style: TextStyle(color: white),),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                        : SizedBox(),   
                      Expanded(
                        child: Column(
                          mainAxisAlignment: output != ''
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: deviceWidth * 0.55,
                              height: deviceHeight * 0.20,
                              child: Shortcuts(
                                shortcuts: _shortcuts,
                                child: Actions(
                                  actions: _actions,
                                  child: TextFormField(
                                    cursorColor: white.withAlpha(80),
                                    maxLines:
                                        null, // Allow unlimited lines, field will grow
                                    keyboardType: TextInputType.multiline,
                                    controller: prompt,
                                    // onFieldSubmitted is no longer needed as Actions handle Enter
                                    style: TextStyle(color: white),
                                    minLines: 2,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: white.withValues(alpha: 0.7),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: white.withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: white.withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: white.withValues(alpha: 0.6),
                                          width: 1.5,
                                        ),
                                      ),
                                      hintText:
                                          "Ask LLM",
                                      hintStyle: TextStyle(
                                        color: white.withValues(alpha: 0.7),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          if (prompt.text.trim().isNotEmpty) {
                                            runPrompt(prompt.text);
                                          }
                                        },
                                        icon: Icon(Icons.search, color: white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            output != ""
                                ? SizedBox(height: 10)
                                : SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      color: white.withAlpha(40),
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context, 
                            builder: (context) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: deviceHeight * .2,
                                  horizontal: deviceWidth * .3,
                                ),
                                decoration: BoxDecoration(
                                  color: backgroundClrLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: MaterialButton(
                                  height: 80,
                                  child: Text("Log Out", style: TextStyle(color: white)),
                                  onPressed: ()=> Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LandingView()), (route) => false)
                                )
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.person_outline_rounded,
                          color: white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsetsGeometry.only(top: deviceHeight*0.6, right: deviceWidth * 0.6),
                //   child: Container(
                //     // height: 50,
                //     width: 250,
                //     // color: white,
                //     child: Column(
                //       children: [
                //         ExpansionTile(
                //           title: Text("Suggestions", style: TextStyle(color: white, fontSize: 15),),
                //           children: [
                //             Wrap(
                //               children: [
                //                 Chip(label: Text("Lorem")),
                //                 Chip(label: Text("Lorem")),
                //                 Chip(label: Text("Lorem")),
                //                 Chip(label: Text("Lorem")),
                //                 Chip(label: Text("Lorem")),
                //                 Chip(label: Text("Lorem")),
                //               ],
                //             )
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  sideBar() {
    return Expanded(
      flex: 1,
      child: Container(
        color: backgroundClrLight,
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Column(
          spacing: 30,
          children: [
            // SizedBox(
            //   height: 20,
            // ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu, color: Colors.white),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.history, color: Colors.white),
            ),
            Spacer(),
            IconButton(
              onPressed: () => clearOutput(),
              icon: Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
