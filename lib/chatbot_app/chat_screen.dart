import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cardiocare/chatbot_app/widgets/chat.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: ChatWidget(),
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
      children: [
        const SizedBox(height: 16),
        Text(
          'CardioBot is a personal health assistant that can help you with your health-related queries. '
          'It uses the latest AI technology to provide you with accurate and reliable information. '
          'Please note that CardioBot is not a substitute for professional medical advice. '
          'Always consult a qualified healthcare provider for any health-related concerns.',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}
