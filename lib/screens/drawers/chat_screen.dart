import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _apiKey = String.fromEnvironment('API_KEY');
const String _systemInstructions = String.fromEnvironment('BOT_INSTRUCTIONS');

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

void _buildAboutBotPage(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationIcon: const FaIcon(FontAwesomeIcons.userDoctor),
    applicationName: 'CardioBot',
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2024 CardioCare Plus Inc.',
    children: [
      const SizedBox(height: 16),
      const Text(
        'CardioBot is a personal health assistant that can help you with your health-related queries. '
        'It uses the latest AI technology to provide you with accurate and reliable information. '
        'Please note that CardioBot is not a substitute for professional medical advice. '
        'Always consult a qualified healthcare provider for any health-related concerns.',
      ),
    ],
  );
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: FaIcon(
                FontAwesomeIcons.userDoctor,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CardioBot'),
                Text(
                  'your personal health assistant',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _buildAboutBotPage(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper_doc.jpeg'),
            opacity: 0.1,
            fit: BoxFit.cover,
          ),
        ),
        child: const ChatWidget(apiKey: _apiKey),
      ),
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
  late ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  List<ChatMessage> _conversationHistory = [];
  bool _loading = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _saveConversationHistory();
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    _prefs = await SharedPreferences.getInstance();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: widget.apiKey,
      systemInstruction: Content.text(_systemInstructions),
    );
    _loadConversationHistory();
    _chat = _model.startChat(
      history: _conversationHistory.map((m) => m.toContent()).toList(),
    );
  }

  void _loadConversationHistory() {
    final savedHistory = _prefs.getStringList('chat_history') ?? [];
    _conversationHistory =
        savedHistory.map((json) => ChatMessage.fromJson(json)).toList();
    setState(() {});
  }

  void _saveConversationHistory() {
    _prefs.setStringList(
      'chat_history',
      _conversationHistory.map((m) => m.toJson()).toList(),
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _restartConversation() {
    setState(() {
      _conversationHistory.clear();
      _chat = _model.startChat();
    });
    _saveConversationHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _conversationHistory.length,
            itemBuilder: (context, index) {
              final message = _conversationHistory[index];
              return MessageWidget(
                text: message.text,
                isFromUser: message.isFromUser,
                status: message.status,
              );
            },
          ),
        ),
        _buildInputRow(),
      ],
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _textFieldFocus,
              decoration: const InputDecoration(
                hintText: 'What is on your mind...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white70,
              ),
              onSubmitted: (text) => _sendChatMessage(text),
            ),
          ),
          if (!_loading)
            IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => _sendChatMessage(_textController.text),
            ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _restartConversation,
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.isEmpty) return;
    _textController.clear();

    setState(() {
      _conversationHistory.add(ChatMessage(
        text: message,
        isFromUser: true,
        status: MessageStatus.sent,
      ));
      _loading = true;
    });

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      if (text != null) {
        setState(() {
          _conversationHistory.add(ChatMessage(
            text: text,
            isFromUser: false,
            status: MessageStatus.sent,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _conversationHistory.last.status = MessageStatus.failed;
      });
    } finally {
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
      _scrollDown();
      _saveConversationHistory();
    }
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
    required this.status,
  });

  final String text;
  final bool isFromUser;
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        shadowColor: Colors.black.withOpacity(0.6),
        color: isFromUser
            ? const Color.fromARGB(255, 245, 185, 180)
            : Colors.white,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isFromUser
                ? MediaQuery.of(context).size.width * 0.8
                : MediaQuery.of(context).size.width,
            minWidth: MediaQuery.of(context).size.width * 0.2,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(data: text),
              if (status == MessageStatus.failed)
                const Icon(Icons.error_outline, color: Colors.red, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  MessageStatus status;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.status,
  });

  factory ChatMessage.fromJson(String json) {
    final map = jsonDecode(json);
    return ChatMessage(
      text: map['text'],
      isFromUser: map['isFromUser'],
      status: MessageStatus.values[map['status']],
    );
  }

  String toJson() {
    return jsonEncode({
      'text': text,
      'isFromUser': isFromUser,
      'status': status.index,
    });
  }

  Content toContent() {
    return Content.text(text);
  }
}

enum MessageStatus { sent, failed }
