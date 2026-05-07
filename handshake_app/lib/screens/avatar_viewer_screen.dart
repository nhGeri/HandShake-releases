import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '../state/user_state.dart';
import '../models/shop_item.dart';
import 'avatar_creator_screen.dart';

class AvatarViewerScreen extends StatefulWidget {
  const AvatarViewerScreen({super.key});

  @override
  State<AvatarViewerScreen> createState() => _AvatarViewerScreenState();
}

class _AvatarViewerScreenState extends State<AvatarViewerScreen> {
  final Flutter3DController controller = Flutter3DController();
  final UserState userState = UserState();
  AccessoryType selectedCategory = AccessoryType.hat;

  @override
  void initState() {
    super.initState();
    userState.addListener(_onStateChanged);
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

  List<ShopItem> _getOwnedItemsByType(AccessoryType type) {
    return allShopItems
        .where((item) =>
            item.category == ShopCategory.accessories &&
            item.accessoryType == type &&
            userState.ownedItems.contains(item.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = userState.avatarUrl != null && userState.avatarUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Avatar testreszabás'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (hasAvatar)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Új avatar készítése',
              onPressed: _openCreator,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ============ 3D AVATAR VIEW ============
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D2137), Color(0xFF252A40)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: hasAvatar
                      ? Stack(
                          children: [
                            // 3D KARAKTER!
                            Flutter3DViewer(
                              controller: controller,
                              src: userState.avatarUrl!,
                              progressBarColor: const Color(0xFF6C63FF),
                            ),
                            // Felvett kiegészítők (overlay-en jobb felül)
                            if (_hasEquippedItems()) _buildEquippedOverlay(),
                            // Forgatás info
                            const Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text(
                                  '👆 Húzd a karaktert a forgatáshoz',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildNoAvatarView(),
                ),
              ),
            ),

            // ============ KATEGÓRIA VÁLASZTÓ ============
            if (hasAvatar) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _categoryChip(AccessoryType.hat, '🧢 Sapka'),
                      _categoryChip(AccessoryType.glasses, '🕶️ Szemüveg'),
                      _categoryChip(AccessoryType.shirt, '👕 Felső'),
                      _categoryChip(AccessoryType.pants, '👖 Nadrág'),
                      _categoryChip(AccessoryType.shoes, '👟 Cipő'),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 2, child: _buildItemList()),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasEquippedItems() {
    return userState.equippedHat != null ||
        userState.equippedShirt != null ||
        userState.equippedPants != null ||
        userState.equippedShoes != null ||
        userState.equippedGlasses != null;
  }

  Widget _buildEquippedOverlay() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text('Felvéve:', style: TextStyle(color: Colors.white60, fontSize: 10)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (userState.equippedHat != null)
                  Text(_getItemById(userState.equippedHat)!.emoji,
                      style: const TextStyle(fontSize: 24)),
                if (userState.equippedGlasses != null)
                  Text(_getItemById(userState.equippedGlasses)!.emoji,
                      style: const TextStyle(fontSize: 24)),
                if (userState.equippedShirt != null)
                  Text(_getItemById(userState.equippedShirt)!.emoji,
                      style: const TextStyle(fontSize: 24)),
                if (userState.equippedPants != null)
                  Text(_getItemById(userState.equippedPants)!.emoji,
                      style: const TextStyle(fontSize: 24)),
                if (userState.equippedShoes != null)
                  Text(_getItemById(userState.equippedShoes)!.emoji,
                      style: const TextStyle(fontSize: 24)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAvatarView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧑', style: TextStyle(fontSize: 100)),
            const SizedBox(height: 20),
            const Text(
              'Még nincs 3D avatarod!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Készíts egyet most! Választhatsz arcot, hajat, szemet, ruhát és sok mást!',
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _openCreator,
              icon: const Icon(Icons.add),
              label: const Text('Készítsd el az avatarodat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AvatarCreatorScreen()),
    );
  }

  Widget _categoryChip(AccessoryType type, String label) {
    final isSelected = selectedCategory == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => selectedCategory = type),
        selectedColor: const Color(0xFF6C63FF),
        backgroundColor: const Color(0xFF1D2137),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
        ),
      ),
    );
  }

  Widget _buildItemList() {
    final items = _getOwnedItemsByType(selectedCategory);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🛒', style: TextStyle(fontSize: 50)),
            SizedBox(height: 12),
            Text(
              'Még nincs ilyen kategóriájú itemed!',
              style: TextStyle(color: Colors.white60),
            ),
            SizedBox(height: 8),
            Text(
              'Menj a Shopba és vegyél!',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEquipped = userState.isEquipped(item.id);

        return GestureDetector(
          onTap: () => userState.equipItem(item),
          child: Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isEquipped
                  ? const Color(0xFF6C63FF).withOpacity(0.3)
                  : const Color(0xFF1D2137),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEquipped ? const Color(0xFF6C63FF) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isEquipped)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('✓ Felvéve', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
