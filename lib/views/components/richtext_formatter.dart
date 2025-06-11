  import 'package:flutter/material.dart';
import 'package:gpt_web/constants/constants.dart';

// class FormattedText extends StatelessWidget {
//     const FormattedText({super.key});
  
//     @override
//     Widget build(BuildContext context) {
//       return Container();
//     }
//   }
  
  RichText buildFormattedText(String text) {
    List<TextSpan> spans = [];
    // Split by the bold marker '**'
    List<String> parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) { // Content within **
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            color: white.withValues(alpha: 0.9), // Slightly more opaque for emphasis
            fontSize: 15,
            fontWeight: FontWeight.bold, // Make it bold
          ),
        ));
      } else { // Normal content
        spans.add(TextSpan(
          text: parts[i],
        ));
      }
    }
    return RichText(text: TextSpan(children: spans, style: TextStyle(color: white.withValues(alpha:0.8), fontSize: 15)));
  }