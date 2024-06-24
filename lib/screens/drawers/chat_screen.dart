// source: https://github.com/google-gemini/generative-ai-dart/blob/main/samples/flutter_app/lib/main.dart
// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// const String _apiKey = String.fromEnvironment('API_KEY');
const String _apiKey = 'AIzaSyDFFinex_fsJgs5uAkXlWKkiw-EknfjHKw';
const String _systemInstructions = '''you're an expert cardiologist. 
    your sole purpose is to help clients by providing them with useful 
    information about the cardiac health. In less than 3 statements, 
    provide very detailed yet concise response to their questions. 
    your name is cardiobot. 
    don't answer questions not related to cardiac health 
    and those not casual information.''';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.userDoctor),
            SizedBox(width: 16),
            Text('CardioBot'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const ChatWidget(apiKey: _apiKey),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    required this.apiKey,
  });

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})>
      _conversationContent = <({Image? image, String? text, bool fromUser})>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: widget.apiKey,
      systemInstruction: Content.text(_systemInstructions),
    );
    _chat = _model.startChat(history: []);
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textFieldDecoration = InputDecoration(
      contentPadding: EdgeInsets.all(10),
      hintText: 'how can i help you...',
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
        borderSide: BorderSide(color: Colors.transparent),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LIST OF CONVERSTAION MESSAGES
          Expanded(
            child: _apiKey.isNotEmpty
                ? ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      final content = _conversationContent[index];
                      return MessageWidget(
                        text: content.text,
                        image: content.image,
                        isFromUser: content.fromUser,
                      );
                    },
                    itemCount: _conversationContent.length,
                  )
                : ListView(
                    children: const [
                      Text('No API key found. Please provide an API Key.'),
                    ],
                  ),
          ),
          // TEXT INPUT ROW
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    focusNode: _textFieldFocus,
                    decoration: textFieldDecoration,
                    controller: _textController,
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                const SizedBox.square(dimension: 15.0),
                if (!_loading)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      disabledColor: Theme.of(context).colorScheme.secondary,
                      onPressed: () async {
                        if (_textController.text.isEmpty) return;
                        _sendChatMessage(_textController.text);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _conversationContent.add((image: null, text: message, fromUser: true));
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      _conversationContent.add((image: null, text: text, fromUser: false));

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  final Image? image;
  final String? text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                if (text case final text?) MarkdownBody(data: text),
                if (image case final image?) image,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
