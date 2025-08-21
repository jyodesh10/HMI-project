import 'dart:async';
import 'dart:developer';

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
  List suggestionsList = [];
  String currentUser = "";
  Timer? debounceTimer; // Declare a Timer variable
  final Duration debounceDuration = Duration(milliseconds: 500);
  List<String> llms = ["Gemini", "Cohere"];
  String selectedLlm = "Gemini";
  List<Map<String, dynamic>> content =[];

  runPromptGemini(val) async {
    setState(() {
      loading = true;
    });
    content.add(
      {
        "role": "user",
        "parts": [
          {
            "text": prompt.text
          },
        ],
      },
    );

    output = await ApiRepo().geminiApiPost(val, content);
    content.add({
        "role": "model",
        "parts": [
          {
            "text": output
          },
        ],
    });
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
      "selectedLLm": selectedLlm,
      "rating": 0.0,
      "date": DateTime.now()

    });

    log(content.toString());
    Future.delayed(Duration(milliseconds: 2), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  runPromptCohere(val) async {
    setState(() {
      loading = true;
    });
    content.add(
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": prompt.text
          }
        ]
      }
    );

    output = await ApiRepo().cohereApiPost(val, content);
    content.add({
        "role": "assistant",
        "content": [
          {
            "type": "text",
            "text": output
          }
        ]
    });
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
      "selectedLLm": selectedLlm,
      "rating": 0.0,
      "date": DateTime.now()
    });

    log(content.toString());
    Future.delayed(Duration(milliseconds: 2), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }



  clearOutput() {
    output = '';
    content.clear();
    history.clear();
    prompt.clear();
    setState(() {});
  }

  // Action handler for submitting the prompt
  void _handleSubmitIntent() {
    if (prompt.text.trim().isNotEmpty) {
      if(selectedLlm == "Gemini") {
        runPromptGemini(prompt.text);
      } else {
        runPromptCohere(prompt.text);
      }
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

  getsuggestions(String value) {
    if (debounceTimer?.isActive ?? false) {
      debounceTimer!.cancel();
    }
    if (value.trim().length > 2) {
      debounceTimer = Timer(debounceDuration, () async {
        String result = await ApiRepo().getSuggestions(value);
        List<String> suggestion = result.split(",").map((e) => e).toList();
        setState(() {
          suggestion.removeAt(suggestion.length-1);
          suggestionsList = suggestion;
        });

      });
    }
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
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldkey,
      backgroundColor: backgroundClr,
      drawer: deviceWidth < 700
        ? Drawer(
          backgroundColor: backgroundClrLight,
          width: deviceWidth * 0.2,
          child: sideBar(deviceWidth),
        )
        : SizedBox(),
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Row(
            children: [
              deviceWidth < 700
                ? SizedBox()
                : Expanded(
                  child: sideBar(deviceWidth),
                ),
              Expanded(
                flex: 8,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    SelectionArea(
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            loading
                                ? SizedBox(
                                    height: deviceHeight * 0.65,
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
                                                          child: SelectableText(history[index]['prompt'], style: TextStyle(color: white),),
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
                                                "Hello, ${widget.user.split("@").first}",
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
                                      children: List.generate(suggestionsList.length, (index) {
                                        return MaterialButton(
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                          elevation: 1,
                                          color: white.withValues(alpha: 0.14),
                                          shape: RoundedSuperellipseBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(suggestionsList[index], style: TextStyle(color: white),),
                                          onPressed: () {
                                            prompt.text = "${prompt.text} ${suggestionsList[index]}";
                                            getsuggestions(prompt.text);
                                          }
                                        );
                                      })
                                    )
                                  ],
                                ),
                              )
                              : SizedBox(),   
                            // textfield
                            Expanded(
                              child: Column(
                                mainAxisAlignment: output != ''
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: deviceWidth * 0.55,
                                    height: deviceHeight * 0.15,
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
                                          onChanged: (value) {
                                            getsuggestions(value);
                                          },
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
                                                  if(selectedLlm == "Gemini") {
                                                    runPromptGemini(prompt.text);
                                                  } else {
                                                    runPromptCohere(prompt.text);
                                                  }
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 60,
                                      vertical: 60
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
                    Positioned(
                      top: 20,
                      left: deviceWidth < 700 ? 80: 10,
                      // padding: EdgeInsets.all(20.0),
                      child: PopupMenuButton(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: torquiseT,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text("Select LLM : $selectedLlm", style: TextStyle(fontSize: 15, color: white, fontWeight: FontWeight.w500),)),
                          itemBuilder: (context) {
                            return llms.map((e) => 
                              PopupMenuItem(
                                child: Text(e),
                                onTap: () {
                                  setState(() {
                                    debugPrint(e);
                                    if(selectedLlm!=e.toString()){
                                      content.clear();
                                      history.clear();
                                      log("ok");
                                      selectedLlm = e.toString();
                                    }
                                  });
                                },
                              ),
                            ).toList();
                          },
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
          deviceWidth < 700
            ? Padding(
              padding: const EdgeInsets.only(left: 20, top: 20),
              child: IconButton(
                onPressed: () {
                  scaffoldkey.currentState!.openDrawer();
                  // debugPrint("Drawer opened");
                }, 
                icon: Icon(Icons.menu, color: white,)
              ),
            )
            : SizedBox()
        ],
      ),
    );
  }

  sideBar(deviceWidth) {
    return Container(
      color: backgroundClrLight,
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Column(
        spacing: 30,
        children: [
          // SizedBox(
          //   height: 20,
          // ),
          deviceWidth < 700
            ? SizedBox()
            : IconButton(
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
    );
  }
}
