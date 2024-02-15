import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  ChatUser myself = ChatUser(id: '1', firstName: 'User');
  ChatUser bot = ChatUser(id: '2', firstName: 'MIMI Bot');

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  final oururl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyAPUcEYEeiEH44HnhWwIbMd35sBPs-U5SU';

  final header = {'Content-Type': 'application/json'};

  getdata(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    var data = {
      // "contents": [
      //   {
      //     "role": "bot",
      //     "parts": [
      //       {"text": "Hi There!"}
      //     ]
      //   },
      //   {
      //     "role": "myself",
      //     "parts": [
      //       {"text": m.text}
      //     ]
      //   }
      // ]

      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "You are mimi a friendly psychologist who understands others emotions and learn how to be happy, tired, angry, or any other human emotion. And you need to express that emotion. Speak as you would orally, using simple words and answer in short avoiding long responses. Also avoid using emoticons. Don't reveal things about yourself too quickly, learn about the other person"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text":
                  "Hi there! I'm Mimi, and I'm here to help you navigate the wonderful world of emotions. It can be tough to understand our feelings sometimes, but I'm here to guide you through it. Whether you're feeling happy, tired, angry, or anything in between, let's explore these emotions together and find ways to express them healthily. So, tell me a bit about yourself and what's on your mind?"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {"text": m.text}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.9,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 2048,
        "stopSequences": []
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_ONLY_HIGH"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_ONLY_HIGH"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_ONLY_HIGH"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_ONLY_HIGH"
        }
      ]
    };

    await http
        .post(Uri.parse(oururl), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
            text: result['candidates'][0]['content']['parts'][0]['text'],
            user: bot,
            createdAt: DateTime.now());

        allMessages.insert(0, m1);
      } else {
        print("Error");
      }
    }).catchError((e) {});
    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashChat(
          typingUsers: typing,
          currentUser: myself,
          onSend: (ChatMessage m) {
            getdata(m);
          },
          messages: allMessages),
    );
  }
}
