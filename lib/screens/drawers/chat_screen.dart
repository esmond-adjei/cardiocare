import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _apiKey = String.fromEnvironment('API_KEY');
const String _systemInstructions = String.fromEnvironment('BOT_INSTRUCTIONS');

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _AppBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutBotDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/wallpaper_doc.jpeg',
              opacity: const AlwaysStoppedAnimation(0.1),
              fit: BoxFit.cover,
            ),
          ),
          const SafeArea(
            child: ChatWidget(apiKey: _apiKey),
          ),
        ],
      ),
    );
  }

  void _showAboutBotDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationIcon: const FaIcon(FontAwesomeIcons.userDoctor),
      applicationName: 'CardioBot',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 CardioCare Plus Inc.',
      children: const [
        SizedBox(height: 16),
        Text(
          'CardioBot is a personal health assistant that can help you with your health-related queries. '
          'It uses the latest AI technology to provide you with accurate and reliable information. '
          'Please note that CardioBot is not a substitute for professional medical advice. '
          'Always consult a qualified healthcare provider for any health-related concerns.',
        ),
      ],
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
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
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key, required this.apiKey});

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
    setState(() {
      _conversationHistory =
          savedHistory.map((json) => ChatMessage.fromJson(json)).toList();
    });
  }

  void _saveConversationHistory() {
    _prefs.setStringList(
      'chat_history',
      _conversationHistory.map((m) => m.toJson()).toList(),
    );
  }

  void _restartConversation() {
    setState(() {
      _conversationHistory.clear();
      _chat = _model.startChat();
    });
    _saveConversationHistory();
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.isEmpty) return;
    _textController.clear();
    _scrollDown();

    setState(() {
      _conversationHistory.add(ChatMessage(
        text: message,
        isFromUser: true,
        status: MessageStatus.loading,
      ));
      _loading = true;
    });

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      dev.log('Received response: $text');
      if (text != null) {
        setState(() {
          _conversationHistory.last.status = MessageStatus.sent;
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
      dev.log("Failed to send message: $e");
    } finally {
      setState(() => _loading = false);
      _textFieldFocus.requestFocus();
      _saveConversationHistory();
    }
      _scrollDown();
  }

  Future<void> _resendMessage(ChatMessage message) async {
    final index = _conversationHistory.indexOf(message);
    setState(() {
      message.status = MessageStatus.loading;
    });

    try {
      final response = await _chat.sendMessage(message.toContent());
      final text = response.text;
      dev.log('Received response: $text');

      if (text != null) {
        setState(() {
          _conversationHistory[index].status = MessageStatus.sent;
          _conversationHistory.insert(
              index + 1,
              ChatMessage(
                text: text,
                isFromUser: false,
                status: MessageStatus.sent,
              ));
        });
      }
    } catch (e) {
      setState(() {
        message.status = MessageStatus.failed;
      });
      dev.log("Failed to resend message: $e");
    } finally {
      _saveConversationHistory();
    }
  }

  void _deleteMessage(ChatMessage message) {
    setState(() => _conversationHistory.remove(message));
    _saveConversationHistory();
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

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.onResend,
    required this.onCopy,
    required this.onDelete,
  });

  final ChatMessage message;
  final VoidCallback onResend;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageActions(context),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          color: message.isFromUser
              ? const Color.fromARGB(255, 245, 185, 180)
              : Colors.white,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: message.isFromUser
                  ? MediaQuery.of(context).size.width * 0.8
                  : MediaQuery.of(context).size.width * 0.9,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(data: message.text),
                if (message.status != MessageStatus.sent && message.isFromUser)
                  Icon(
                    message.status == MessageStatus.loading
                        ? Icons.query_builder
                        : Icons.error_outline,
                    color: message.status == MessageStatus.loading
                        ? Colors.blue
                        : Colors.red,
                    size: 12,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('Copy'),
                onTap: () {
                  onCopy();
                  Navigator.pop(context);
                },
              ),
              if (message.isFromUser && message.status == MessageStatus.failed)
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Resend'),
                  onTap: () {
                    onResend();
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  onDelete();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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
              decoration: const InputDecoration(
                hintText: 'What is on your mind...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white70,
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

enum MessageStatus { sent, loading, failed }
