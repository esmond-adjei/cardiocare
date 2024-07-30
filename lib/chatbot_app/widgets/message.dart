import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cardiocare/chatbot_app/chat_model.dart';

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
              ? Theme.of(context).colorScheme.tertiary
              // const Color.fromARGB(255, 245, 185, 180)
              : Theme.of(context).colorScheme.secondary,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width *
                  (message.isFromUser ? 0.8 : 0.9),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
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
