import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../state/user_state.dart';

enum NfcState { scanning, success, error, noNfc }

class HandshakeScreen extends StatefulWidget {
  const HandshakeScreen({super.key});

  @override
  State<HandshakeScreen> createState() => _HandshakeScreenState();
}

class _HandshakeScreenState extends State<HandshakeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  NfcState _nfcState = NfcState.scanning;
  String _statusText = 'Érintsd össze a telefonokat!';
  String? _foundFriendName;
  final UserState _userState = UserState();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startNfc();
  }

  @override
  void dispose() {
    _controller.dispose();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> _startNfc() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      if (mounted) {
        setState(() {
          _nfcState = NfcState.noNfc;
          _statusText = 'Az NFC ki van kapcsolva vagy nem támogatott!';
        });
      }
      return;
    }

    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);

          if (ndef != null) {
            final message = ndef.cachedMessage;
            if (message != null && message.records.isNotEmpty) {
              for (var record in message.records) {
                // A payload első byte-ja gyakran a nyelvi kód hossza (pl. 'en' esetén 2)
                // Ezért keressük a kulcsszót a teljes payloadban
                final payload = String.fromCharCodes(record.payload);
                if (payload.contains('handshake:')) {
                  final startIndex = payload.indexOf('handshake:') + 'handshake:'.length;
                  final jsonStr = payload.substring(startIndex);
                  final data = jsonDecode(jsonStr);
                  final friendName = data['name'] ?? 'Ismeretlen';

                  if (mounted) {
                    setState(() {
                      _nfcState = NfcState.success;
                      _foundFriendName = friendName;
                      _statusText = '🎉 Sikeres HandShake!';
                      _controller.stop();
                    });
                  }
                  _userState.addHandshake(friendName);
                  await NfcManager.instance.stopSession();
                  return;
                }
              }
            }

            // ÍRÁS
            if (ndef.isWritable) {
              final myData = jsonEncode({
                'name': _userState.displayName,
                'app': 'HandShake',
              });
              
              // Itt az NdefRecord.createText használata a legbiztosabb
              final ndefMessage = NdefMessage([
                NdefRecord.createText('handshake:$myData'),
              ]);

              await ndef.write(ndefMessage);
              
              if (mounted) {
                setState(() {
                  _statusText = 'Adatok átadva! Várjuk a választ...';
                });
              }
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _nfcState = NfcState.error;
              _statusText = 'Hiba: $e';
            });
          }
          await NfcManager.instance.stopSession();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('HandShake', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _nfcState == NfcState.success
                    ? '🤝 ÖSSZEJÖTT!'
                    : _nfcState == NfcState.error
                        ? '❌ HIBA'
                        : _nfcState == NfcState.noNfc
                            ? '📵 NFC HIÁNYZIK'
                            : 'KÉSZEN ÁLLSZ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _nfcState == NfcState.success
                      ? Colors.green
                      : _nfcState == NfcState.error
                          ? Colors.red
                          : Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 50),

              if (_nfcState == NfcState.scanning)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200 + (50 * _controller.value),
                          height: 200 + (50 * _controller.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 1 - _controller.value),
                              width: 3,
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.3),
                                Colors.blue.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: const Icon(Icons.nfc, size: 100, color: Colors.blue),
                        ),
                      ],
                    );
                  },
                )
              else if (_nfcState == NfcState.success)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const Icon(Icons.handshake, size: 100, color: Colors.green),
                )
              else
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: const Icon(Icons.error_outline, size: 100, color: Colors.red),
                ),

              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),

              if (_nfcState == NfcState.success && _foundFriendName != null) ...[
                const SizedBox(height: 16),
                Text(
                  '+ $_foundFriendName',
                  style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: 40),

              if (_nfcState == NfcState.success)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                  child: const Text('Kész', style: TextStyle(color: Colors.white)),
                )
              else
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mégse', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}