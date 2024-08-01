import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cardiocare/chatbot_app/chat_screen.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
// import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final Widget child;
  final String shareText;
  final dynamic signal;

  const ShareButton({
    super.key,
    required this.child,
    required this.shareText,
    required this.signal,
  });

  Future<void> _shareContent(BuildContext context, String shareOption) async {
    // final screenshotController = ScreenshotController();
    // final bytes = await screenshotController.captureFromWidget(
    //   MaterialApp(
    //     home: Scaffold(
    //       body: child,
    //     ),
    //   ),
    // );

    // final directory = await getTemporaryDirectory();
    // final imagePath = '${directory.path}/screenshot.png';
    // final imageFile = File(imagePath);
    // await imageFile.writeAsBytes(bytes);

    if (shareOption == 'external') {
      // await Share.shareFiles([imagePath], text: shareText);
    } else if (shareOption == 'cardiocare') {
      final String message =
          "Could you explain this measured ecg result to me: ${signal.toMap().toString()} "
          "data: ${signal.ecgData}";
      dev.log('Sharing with Cardiocare chatbot: $message');
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(sharedMessage: message),
        ),
      );
    }
  }

  void _showShareOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Data'),
          content: const Text('Choose where you would like to share your data'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareContent(context, 'cardiocare');
              },
              child: const Text('Cardiocare Chatbot'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareContent(context, 'external');
              },
              child: const Text('External Share'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showShareOptions(context),
    );
  }
}
