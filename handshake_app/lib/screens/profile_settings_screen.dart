import 'package:flutter/material.dart';
import '../state/user_state.dart';
import '../models/shop_item.dart';
import 'avatar_viewer_screen.dart';
import '../services/update_service.dart';
import 'update_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final UserState userState = UserState();

  bool _isCheckingUpdate = false;
  String? _currentVersion;

  @override
  void initState() {
    super.initState();
    userState.addListener(_onStateChanged);
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final version = await UpdateService.getCurrentVersion();
    if (mounted) {
      setState(() => _currentVersion = version);
    }
  }

  Future<void> _checkForUpdate() async {
    setState(() => _isCheckingUpdate = true);

    final updateInfo = await UpdateService.checkForUpdate();

    if (!mounted) return;

    setState(() => _isCheckingUpdate = false);

    if (updateInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Nem sikerült ellenőrizni a frissítést'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!updateInfo.isNewerThanCurrent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('✅ Az alkalmazás naprakész!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // Új verzió van!
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(updateInfo: updateInfo),
    );
  }

  @override
  void dispose() {
    userState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() => setState(() {});

  ShopItem? _getItemById(String? id) {
    if (id == null) return null;
    try {
      return allShopItems.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownedCollectibles = allShopItems
        .where((i) => i.category == ShopCategory.collectibles && userState.ownedItems.contains(i.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PROFIL KÁRTYA AVATARRAL
          Card(
            color: const Color(0xFF1D2137),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Mini avatar
                  SizedBox(
                    width: 100,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        const Positioned(
                          top: 30,
                          child: Text('🧑', style: TextStyle(fontSize: 90)),
                        ),
                        if (userState.equippedHat != null)
                          Positioned(
                            top: 0,
                            child: Text(_getItemById(userState.equippedHat)!.emoji,
                                style: const TextStyle(fontSize: 35)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(userState.displayName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stat('🔥', '${userState.currentStreak}', 'Streak'),
                      const SizedBox(width: 24),
                      _stat('🤝', '${userState.totalHandshakes}', 'Kézfogás'),
                      const SizedBox(width: 24),
                      _stat('⭐', '${userState.points}', 'Pont'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AvatarViewerScreen()),
                        );
                      },
                      icon: const Icon(Icons.face),
                      label: const Text('Avatar testreszabása'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Verziószám badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, size: 13, color: Colors.white38),
                        const SizedBox(width: 5),
                        Text(
                          _currentVersion != null ? 'v$_currentVersion' : 'v...',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // QR KÓD KÁRTYA - App letöltés
          Card(
            color: const Color(0xFF1D2137),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('📲 App letöltése', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Szkenneld be a QR kódot a HandShake letöltéséhez!',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: 'https://github.com/nhGeri/HandShake-releases/releases/latest',
                      version: QrVersions.auto,
                      size: 180.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E21),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'github.com/nhGeri/HandShake-releases',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(
                              text: 'https://github.com/nhGeri/HandShake-releases/releases/latest',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📋 Link másolva!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Link másolása'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse('https://github.com/nhGeri/HandShake-releases/releases/latest'),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Letöltés'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // FRISSÍTÉS KERESÉS GOMB
          Card(
            color: const Color(0xFF1D2137),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isCheckingUpdate
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.system_update, color: Colors.white),
              ),
              title: const Text('Frissítés keresése'),
              subtitle: Text(
                _currentVersion != null
                    ? 'Jelenlegi verzió: v$_currentVersion'
                    : 'Ellenőrizd, van-e új verzió',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _isCheckingUpdate ? null : _checkForUpdate,
            ),
          ),
          const SizedBox(height: 8),

          // GYŰJTEMÉNY
          if (ownedCollectibles.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('🎁 Gyűjteményed', style: TextStyle(color: Colors.white60, fontSize: 14)),
            ),
            Card(
              color: const Color(0xFF1D2137),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ownedCollectibles.map((item) {
                    final color = rarityColor(item.rarity);
                    return Container(
                      width: 70,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 32)),
                          Text(item.name,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ADATVÉDELEM
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('Adatvédelem', style: TextStyle(color: Colors.white60, fontSize: 14)),
          ),
          _switchTile(
            'Helymeghatározás megosztása',
            'A barátaid látják, hol vagy',
            Icons.location_on,
            userState.shareLocation,
            (val) => userState.toggleShareLocation(val),
          ),
          _switchTile(
            'Utoljára látva',
            'Mikor voltál utoljára aktív',
            Icons.access_time,
            userState.showLastSeen,
            (val) => userState.toggleShowLastSeen(val),
          ),
          _switchTile(
            'Helyszín név mutatása',
            'Pl. "Parlamentnél" jelenik meg',
            Icons.place,
            userState.showCurrentLocation,
            (val) => userState.toggleShowCurrentLocation(val),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _switchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Card(
      color: const Color(0xFF1D2137),
      child: SwitchListTile(
        secondary: Icon(icon, color: const Color(0xFF6C63FF)),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6C63FF),
      ),
    );
  }
}
