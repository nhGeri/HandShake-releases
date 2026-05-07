import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../state/user_state.dart';
import 'profile_settings_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  final UserState userState = UserState();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    userState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    userState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() => setState(() {});

  List<ShopItem> _getItemsByCategory(ShopCategory cat) {
    return allShopItems.where((item) => item.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          // Streak badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.deepOrange, Colors.red]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text('${userState.currentStreak}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Pontok
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('${userState.points}',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Profil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Text('🎟️', style: TextStyle(fontSize: 20)), text: 'Kuponok'),
            Tab(icon: Text('👕', style: TextStyle(fontSize: 20)), text: 'Kiegészítők'),
            Tab(icon: Text('🎁', style: TextStyle(fontSize: 20)), text: 'Gyűjthetők'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemGrid(_getItemsByCategory(ShopCategory.coupons)),
          _buildItemGrid(_getItemsByCategory(ShopCategory.accessories)),
          _buildItemGrid(_getItemsByCategory(ShopCategory.collectibles)),
        ],
      ),
    );
  }

  Widget _buildItemGrid(List<ShopItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = userState.ownedItems.contains(item.id);
        final canAfford = userState.points >= item.price;
        final color = rarityColor(item.rarity);

        return Card(
          color: const Color(0xFF1D2137),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.5), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Ritkaság badge
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color, width: 1),
                    ),
                    child: Text(
                      rarityName(item.rarity),
                      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Emoji
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.color.withOpacity(0.3),
                          item.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text('${item.price}',
                        style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: isOwned || !canAfford
                        ? null
                        : () {
                            userState.buyItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Megvetted: ${item.name}!'),
                                backgroundColor: color,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: color,
                    ),
                    child: Text(
                      isOwned ? '✅ Megvan' : 'Megveszem',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}