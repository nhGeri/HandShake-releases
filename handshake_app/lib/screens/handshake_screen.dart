import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../state/user_state.dart';

enum HandshakeMode { initial, success, error }

class HandshakeScreen extends StatefulWidget {
  const HandshakeScreen({super.key});

  @override
  State<HandshakeScreen> createState() => _HandshakeScreenState();
}

class _HandshakeScreenState extends State<HandshakeScreen> {
  HandshakeMode _mode = HandshakeMode.initial;
  String? _foundFriendName;
  final UserState _userState = UserState();
  bool _isProcessing = false;

  void _onSuccess(String friendName) {
    if (_isProcessing) return;
    _isProcessing = true;
    
    if (mounted) {
      setState(() {
        _mode = HandshakeMode.success;
        _foundFriendName = friendName;
      });
    }
    _userState.addHandshake(friendName);
  }

  @override
  Widget build(BuildContext context) {
    final myData = jsonEncode({
      'name': _userState.displayName,
      'app': 'HandShake',
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('HandShake', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: _mode == HandshakeMode.success 
            ? _buildSuccessView() 
            : Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'MUTASD MEG A KÓDOD!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 20),
                  
                  // SAJÁT QR KÓD
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: myData,
                        version: QrVersions.auto,
                        size: 180.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  const Divider(color: Colors.white24, thickness: 1, indent: 40, endIndent: 40),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'VAGY OLVASD BE A MÁSIKÉT!',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1),
                  ),
                  const SizedBox(height: 20),

                  // SZKENNER
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: MobileScanner(
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              try {
                                final data = jsonDecode(barcode.rawValue!);
                                if (data['app'] == 'HandShake' && data['name'] != null) {
                                  _onSuccess(data['name']);
                                  break;
                                }
                              } catch (_) {
                                // Nem érvényes kód, hagyjuk
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mégse', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 120, color: Colors.green),
          const SizedBox(height: 30),
          const Text(
            'SIKERES KAPCSOLÓDÁS!',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '+ $_foundFriendName',
            style: const TextStyle(color: Colors.green, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Kész', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}