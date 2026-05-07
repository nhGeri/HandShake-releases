import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../state/user_state.dart';

class AvatarEditorScreen extends StatefulWidget {
  const AvatarEditorScreen({super.key});

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> with SingleTickerProviderStateMixin {
  final UserState userState = UserState();
  AccessoryType selectedCategory = AccessoryType.hat;

  late AnimationController _rotationController;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    userState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    userState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() => setState(() {});

  void _toggleRotation() {
    setState(() {
      _isRotating = !_isRotating;
      if (_isRotating) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
  }

  // Megkeres egy item-et ID alapján
  ShopItem? _getItemById(String? id) {
    if (id == null) return null;
    try {
      return allShopItems.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  // Visszaadja a felhasználó tulajdonában lévő, adott típusú itemeket
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
    final hat = _getItemById(userState.equippedHat);
    final shirt = _getItemById(userState.equippedShirt);
    final pants = _getItemById(userState.equippedPants);
    final shoes = _getItemById(userState.equippedShoes);
    final glasses = _getItemById(userState.equippedGlasses);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Avatar testreszabás'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KARAKTER NÉZET
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Forgó padló (pulzálás imitálja a forgást)
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        final scale = 1.0 + 0.1 * _rotationController.value;
                        return Container(
                          width: 200 * scale,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(100),
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF6C63FF).withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          margin: const EdgeInsets.only(top: 250),
                        );
                      },
                    ),

                    // KARAKTER (rétegekkel)
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        // 360°-os forgás
                        final angle = _rotationController.value * 2 * 3.14159;
                        final scaleX = (angle).abs() % (3.14159) < 1.57
                            ? 1.0
                            : -1.0; // tükrözés
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..scale(scaleX, 1.0),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 180,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Test (alap)
                            const Positioned(
                              top: 50,
                              child: Text('🧑', style: TextStyle(fontSize: 180)),
                            ),
                            // Sapka
                            if (hat != null)
                              Positioned(
                                top: 0,
                                child: Text(hat.emoji, style: const TextStyle(fontSize: 60)),
                              ),
                            // Szemüveg
                            if (glasses != null)
                              Positioned(
                                top: 90,
                                child: Text(glasses.emoji, style: const TextStyle(fontSize: 40)),
                              ),
                            // Felső
                            if (shirt != null)
                              Positioned(
                                top: 130,
                                child: Text(shirt.emoji, style: const TextStyle(fontSize: 70)),
                              ),
                            // Nadrág
                            if (pants != null)
                              Positioned(
                                top: 200,
                                child: Text(pants.emoji, style: const TextStyle(fontSize: 60)),
                              ),
                            // Cipő
                            if (shoes != null)
                              Positioned(
                                top: 250,
                                child: Text(shoes.emoji, style: const TextStyle(fontSize: 50)),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Forgatás gomb
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        onPressed: _toggleRotation,
                        backgroundColor: const Color(0xFF6C63FF),
                        child: Icon(_isRotating ? Icons.pause : Icons.refresh),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // KATEGÓRIA VÁLASZTÓ
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

            // ITEM LISTA
            Expanded(
              flex: 2,
              child: _buildItemList(),
            ),
          ],
        ),
      ),
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
          children: [
            const Text('🛒', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            const Text(
              'Még nincs ilyen kategóriájú itemed!',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 8),
            const Text(
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
