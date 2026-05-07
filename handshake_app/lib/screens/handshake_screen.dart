import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:ndef_record/ndef_record.dart';

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
  String _debugLog = ''; // Ez segít látni mi történik a háttérben
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

  void _addLog(String msg) {
    debugPrint('NFC: $msg');
    if (mounted) {
      setState(() {
        _debugLog = '$msg\n${_debugLog.split('\n').take(3).join('\n')}';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> _startNfc() async {
    _addLog('NFC Session indítása...');
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      if (mounted) {
        setState(() {
          _nfcState = NfcState.noNfc;
          _statusText = 'Az NFC ki van kapcsolva!';
        });
      }
      return;
    }

    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        _addLog('Eszköz észlelve!');
        try {
          final ndef = NdefAndroid.from(tag);

          if (ndef == null) {
            _addLog('Hiba: Nem NDEF kompatibilis eszköz.');
            return;
          }

          // 1. OLVASÁS PRÓBÁJA
          final message = ndef.cachedNdefMessage;
          bool foundHandshake = false;

          if (message != null && message.records.isNotEmpty) {
            _addLog('${message.records.length} rekord találva.');
            for (var record in message.records) {
              final payloadRaw = record.payload;
              if (payloadRaw.length < 3) continue;

              // Az első pár bájt a metadata, utána jön a szöveg
              final payloadStr = String.fromCharCodes(payloadRaw);
              _addLog('Adat: ${payloadStr.length > 20 ? payloadStr.substring(0, 20) : payloadStr}...');

              if (payloadStr.contains('handshake:')) {
                final startIndex = payloadStr.indexOf('handshake:') + 'handshake:'.length;
                final jsonStr = payloadStr.substring(startIndex);
                final data = jsonDecode(jsonStr);
                final friendName = data['name'] ?? 'Ismeretlen';

                _onSuccess(friendName);
                foundHandshake = true;
                break;
              }
            }
          }

          // 2. ÍRÁS: Ha mi vagyunk az elsők, ráírjuk a sajátunkat
          if (!foundHandshake && ndef.isWritable) {
            _addLog('Írás indítása...');
            final myData = jsonEncode({
              'name': _userState.displayName,
              'app': 'HandShake',
            });
            
            final content = 'handshake:$myData';
            final textBytes = utf8.encode(content);
            // 0x02 = lang length, 'en' = language
            final payload = Uint8List.fromList([0x02, 0x65, 0x6E, ...textBytes]);

            final record = NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x54]), // 'T'
              identifier: Uint8List.fromList([]),
              payload: payload,
            );

            await ndef.writeNdefMessage(NdefMessage(records: [record]));
            _addLog('Sikeres írás! Várjuk a választ.');
            if (mounted) {
              setState(() {
                _statusText = 'Adatok átadva! Most a másik telefon olvassa...';
              });
            }
          }
        } catch (e) {
          _addLog('HIBA: $e');
        }
      },
    );
  }

  void _onSuccess(String friendName) {
    if (mounted) {
      setState(() {
        _nfcState = NfcState.success;
        _foundFriendName = friendName;
        _statusText = '🎉 Sikeres HandShake!';
        _controller.stop();
      });
    }
    _userState.addHandshake(friendName);
    NfcManager.instance.stopSession();
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _nfcState == NfcState.success
                          ? '🤝 ÖSSZEJÖTT!'
                          : _nfcState == NfcState.error
                              ? '❌ HIBA'
                              : 'KÉSZEN ÁLLSZ?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _nfcState == NfcState.success ? Colors.green : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Fő animált ikon
                    _buildMainIcon(),

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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Kész', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // DEBUG LOG PANEL - Ez segít látni a hibát!
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rendszer üzenetek:', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _debugLog.isEmpty ? 'Várakozás eszközre...' : _debugLog,
                    style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainIcon() {
    if (_nfcState == NfcState.scanning) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150 + (50 * _controller.value),
                height: 150 + (50 * _controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withValues(alpha: 1 - _controller.value), width: 2),
                ),
              ),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: const Icon(Icons.nfc, size: 80, color: Colors.blue),
              ),
            ],
          );
        },
      );
    } else if (_nfcState == NfcState.success) {
      return const Icon(Icons.check_circle, size: 150, color: Colors.green);
    } else {
      return const Icon(Icons.error, size: 150, color: Colors.red);
    }
  }
}