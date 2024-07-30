import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:cardiocare/chatbot_app/chat_model.dart';
import 'package:cardiocare/chatbot_app/widgets/message.dart';
import 'package:cardiocare/services/db_helper.dart';

const String _apiKey =
// String.fromEnvironment('API_KEY');
    "AIzaSyDFFinex_fsJgs5uAkXlWKkiw-EknfjHKw";
const String _systemInstructions =
//  String.fromEnvironment('BOT_INSTRUCTIONS');
    "you're an expert cardiologist. your sole purpose is to help clients by providing them with useful information about the cardiac health. In less than 3 statements, provide very detailed yet concise response to their questions. your name is cardiobot. don't answer questions not related to cardiac health and those not casual information.";

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

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
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    dev.log("what is the api key? $_apiKey");

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      systemInstruction: Content.text(_systemInstructions),
    );
    _conversationHistory = await _dbHelper.getChatHistory(1);
    _chat = _model.startChat(
      history: _conversationHistory.map((m) => m.toContent()).toList(),
    );
    setState(() {}); // Trigger a rebuild after loading the chat history
  }

  void _restartConversation() async {
    setState(() {
      _conversationHistory.clear();
      _chat = _model.startChat();
    });
    await _dbHelper.clearChatHistory(1);
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.isEmpty) return;

    _textController.clear();
    _scrollDown();

    final userMessage = ChatMessage(
      text: message,
      isFromUser: true,
      status: MessageStatus.loading,
    );

    setState(() {
      _conversationHistory.add(userMessage);
      _loading = true;
    });

    try {
      await _dbHelper.createChatMessage(1, userMessage);
      final response = await _chat.sendMessage(userMessage.toContent());
      final text = response.text;
      if (text != null) {
        final botMessage = ChatMessage(
          text: text,
          isFromUser: false,
          status: MessageStatus.sent,
        );

        setState(() {
          _conversationHistory.last.status = MessageStatus.sent;
          _conversationHistory.add(botMessage);
        });
        await _dbHelper.createChatMessage(1, botMessage);
        await _dbHelper.updateChatMessageStatus(
          userMessage.timestamp,
          MessageStatus.sent,
        );
      }
    } catch (e) {
      await _dbHelper.updateChatMessageStatus(
        _conversationHistory.last.timestamp,
        MessageStatus.failed,
      );
      setState(() => _conversationHistory.last.status = MessageStatus.failed);
      dev.log("Failed to send message: $e");
    } finally {
      setState(() => _loading = false);
      _textFieldFocus.requestFocus();
    }

    _scrollDown();
  }

  Future<void> _resendMessage(ChatMessage message) async {
    final index = _conversationHistory.indexOf(message);
    setState(() {
      message.status = MessageStatus.loading;
      _loading = true;
    });

    try {
      final response = await _chat.sendMessage(message.toContent());
      final text = response.text;
      if (text != null) {
        final botMessage = ChatMessage(
          text: text,
          isFromUser: false,
          status: MessageStatus.sent,
        );

        setState(() {
          _conversationHistory[index].status = MessageStatus.sent;
          _conversationHistory.insert(index + 1, botMessage);
        });
        await _dbHelper.createChatMessage(1, botMessage);
        await _dbHelper.updateChatMessageStatus(
            message.timestamp, MessageStatus.sent);
      }
    } catch (e) {
      setState(() => message.status = MessageStatus.failed);
      dev.log("Failed to resend message: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    setState(() => _conversationHistory.remove(message));
    await _dbHelper.deleteChatMessage(message.timestamp);
  }

  void _copyMessage(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
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
                message: message,
                onResend: () => _resendMessage(message),
                onCopy: () => _copyMessage(message),
                onDelete: () => _deleteMessage(message),
              );
            },
          ),
        ),
        _InputRow(
          textController: _textController,
          focusNode: _textFieldFocus,
          onSend: _sendChatMessage,
          onRestart: _restartConversation,
          loading: _loading,
        ),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.textController,
    required this.focusNode,
    required this.onSend,
    required this.onRestart,
    required this.loading,
  });

  final TextEditingController textController;
  final FocusNode focusNode;
  final Function(String) onSend;
  final VoidCallback onRestart;
  final bool loading;

  @override
  Widget build(BuildContext context) {
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
              controller: textController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'What is on your mind...',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              onSubmitted: onSend,
            ),
          ),
          if (!loading)
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () => onSend(textController.text),
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }
}
