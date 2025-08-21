
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpt_web/constants/constants.dart';
import 'package:http/http.dart' as http;

class ApiRepo {
  Future<String> geminiApiPost(String prompt, List<Map<String, dynamic>> content) async {
    try {
      final res = await http.post(
        Uri.parse(baseurl),
        body: jsonEncode(
          {
            "contents": content
          },
        ) 
      );
      if (res.statusCode == 200) {
        var data =  json.decode(res.body);
        return data['candidates'][0]['content']['parts'][0]['text'].toString();
      } else {
        debugPrint("API request failed with status: ${res.statusCode}, body: ${res.body}");
        return "Error: API request failed (${res.statusCode}).";
      }
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> cohereApiPost(String prompt, List<Map<String, dynamic>> content) async {
    try {
      final res = await http.post(
        Uri.parse(baseurl2),
        body: jsonEncode(
          {
            "messages": content,
            "temperature": 0.3,
            "model": "command-a-03-2025"
          }
        ),
        headers: {
          "Authorization": "Bearer $cohereKey",
          "Content-Type": "application/json"
        }
      );
      if (res.statusCode == 200) {
        var data =  json.decode(res.body);
        return data['message']['content'][0]['text'].toString();
      } else {
        debugPrint("API request failed with status: ${res.statusCode}, body: ${res.body}");
        return "Error: API request failed (${res.statusCode}).";
      }
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> getSuggestions(partialText) async {
    try {
      final prompt = "Given the partial text '$partialText', provide 8-10 concise, comma-separated suggestions to complete the thought or query. Focus on common continuations or related topics. Do not number or list the suggestions; just provide the comma-separated string. Example: 'benefits of AI, challenges of AI, applications of AI'";
      final res = await http.post(
        Uri.parse(baseurl),
        body: jsonEncode(
          {
            "contents": [
              {
                "parts": [
                  {"text": prompt},
                ],
              },
            ],
          },
        ) 
      );
      if (res.statusCode == 200) {
        var data =  json.decode(res.body);
        // var suggestions = 
        return data['candidates'][0]['content']['parts'][0]['text'].toString();
      } else {
        debugPrint("API request failed with status: ${res.statusCode}, body: ${res.body}");
        return "Error: API request failed (${res.statusCode}).";
      }
    } on Exception catch (e) {
      return e.toString();
    }

  }
}
