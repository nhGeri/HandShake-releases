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
    // NFC elérhetőség ellenőrzése
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      if (mounted) {
        setState(() {
          _nfcState = NfcState.noNfc;
          _statusText = 'Ez a telefon nem támogatja az NFC-t, vagy ki van kapcsolva!';
        });
      }
      return;
    }

    // NFC session indítás - NDEF olvasás + írás egyszerre
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // 1. Megpróbáljuk kiolvasni az NFC taget
          final ndef = Ndef.from(tag);

          if (ndef != null) {
            // OLVASÁS: van-e rajta HandShake adat?
            final cachedMessage = ndef.cachedMessage;
            if (cachedMessage != null && cachedMessage.records.isNotEmpty) {
              final record = cachedMessage.records.first;
              final payload = String.fromCharCodes(record.payload.skip(3));

              if (payload.startsWith('handshake:')) {
                // Megtaláltuk a barát adatait!
                final data = jsonDecode(payload.substring('handshake:'.length));
                final friendName = data['name'] ?? 'Ismeretlen';

                if (mounted) {
                  setState(() {
                    _nfcState = NfcState.success;
                    _foundFriendName = friendName;
                    _statusText = '🎉 Sikeres HandShake!';
                    _controller.stop();
                  });
                }

                // Pontot adjunk és kézfogást növelünk
                _userState.addHandshake(friendName);

                await NfcManager.instance.stopSession();
                return;
              }
            }

            // ÍRÁS: ha a tag üres/nem HandShake, írjuk rá a saját adatainkat
            if (ndef.isWritable) {
              final myData = jsonEncode({
                'name': _userState.displayName,
                'app': 'HandShake',
                'version': '1.1.0',
              });

              final message = NdefMessage([
                NdefRecord.createText('handshake:$myData'),
              ]);

              await ndef.write(message);

              if (mounted) {
                setState(() {
                  _statusText = 'Adatok elküldve! Várjuk a másik telefont...';
                });
              }
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _nfcState = NfcState.error;
              _statusText = 'Hiba történt: $e';
            });
          }
          await NfcManager.instance.stopSession(errorMessage: 'Hiba: $e');
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
              // Állapot-specifikus fejléc szöveg
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

              // Animált kör / státusz ikon
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
                              color: Colors.blue.withOpacity(1 - _controller.value),
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
                                Colors.blue.withOpacity(0.3),
                                Colors.blue.withOpacity(0.1),
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
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.15),
                          border: Border.all(color: Colors.green, width: 3),
                        ),
                        child: const Icon(Icons.handshake, size: 100, color: Colors.green),
                      ),
                    );
                  },
                )
              else
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_nfcState == NfcState.error ? Colors.red : Colors.orange)
                        .withOpacity(0.15),
                    border: Border.all(
                      color: _nfcState == NfcState.error ? Colors.red : Colors.orange,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _nfcState == NfcState.error ? Icons.error_outline : Icons.nfc_outlined,
                    size: 100,
                    color: _nfcState == NfcState.error ? Colors.red : Colors.orange,
                  ),
                ),

              const SizedBox(height: 50),

              // Állapot szöveg
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),

              // Sikeres párosítás esetén barát neve
              if (_nfcState == NfcState.success && _foundFriendName != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.4)),
                  ),
                  child: Text(
                    '+ $_foundFriendName',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '+10 pont • Streak növelve!',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],

              const SizedBox(height: 40),

              // Gombok
              if (_nfcState == NfcState.success)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Visszatérés'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                )
              else ...[
                if (_nfcState == NfcState.error || _nfcState == NfcState.noNfc)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _nfcState = NfcState.scanning;
                          _statusText = 'Érintsd össze a telefonokat!';
                        });
                        _startNfc();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Újrapróbálás'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                  child: const Text(
                    'Mégse',
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}