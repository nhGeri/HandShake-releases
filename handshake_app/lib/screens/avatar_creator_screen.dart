import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../state/user_state.dart';

class AvatarCreatorScreen extends StatefulWidget {
  const AvatarCreatorScreen({super.key});

  @override
  State<AvatarCreatorScreen> createState() => _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends State<AvatarCreatorScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController();
    
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller.setBackgroundColor(const Color(0xFF0A0E21));
      _controller.addJavaScriptChannel(
        'Avatar',
        onMessageReceived: (message) {
          _onAvatarCreated(message.message);
        },
      );
    }

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) {
          setState(() => _isLoading = false);
          if (!kIsWeb) {
            _controller.runJavaScript('''
              window.addEventListener('message', function(event) {
                if (event.data && typeof event.data === 'string') {
                  if (event.data.includes('.glb')) {
                    Avatar.postMessage(event.data);
                  }
                }
              });
            ''');
          }
        },
      ),
    );
    
    _controller.loadRequest(Uri.parse(
      'https://demo.readyplayer.me/avatar?frameApi&clearCache',
    ));
  }

  void _onAvatarCreated(String avatarUrl) {
    UserState().setAvatarUrl(avatarUrl);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Avatar elkészítve!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, avatarUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Készítsd el az avatarodat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF0A0E21),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    SizedBox(height: 20),
                    Text(
                      'Karakter készítő betöltése...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          if (kIsWeb)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Minta 3D karakter URL webes teszthez
                  _onAvatarCreated('https://models.readyplayer.me/64b553e1f0e21a44e514cb91.glb');
                },
                child: const Text(
                  'Böngészős teszt: Kész karakter betöltése', 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
        ],
      ),
    );
  }
}
