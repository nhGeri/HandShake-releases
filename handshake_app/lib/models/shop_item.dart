import 'package:flutter/material.dart';

enum ShopCategory {
  coupons,    // Kuponok
  accessories, // Kiegészítők (avatarra)
  collectibles, // Vicces gyűjthető figurák
}

enum AccessoryType {
  hat,    // Sapka
  shirt,  // Felső (póló, pulcsi)
  pants,  // Nadrág
  shoes,  // Cipő
  glasses, // Szemüveg
  none,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopCategory category;
  final AccessoryType accessoryType; // Csak accessories esetén
  final String emoji; // 2D-hez emojival jelenítjük meg
  final Color color;
  final String? rarity; // 'common', 'rare', 'epic', 'legendary'

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.accessoryType = AccessoryType.none,
    required this.emoji,
    this.color = Colors.purple,
    this.rarity = 'common',
  });
}

// DEMO SHOP TARTALOM
final List<ShopItem> allShopItems = [
  // ============ KUPONOK ============
  ShopItem(
    id: 'coupon_starbucks',
    name: 'Starbucks 10%',
    description: '10% kedvezmény Starbucks-ban',
    price: 200,
    category: ShopCategory.coupons,
    emoji: '☕',
    color: Colors.brown,
    rarity: 'rare',
  ),
  ShopItem(
    id: 'coupon_bk',
    name: 'Burger King 1+1',
    description: '1 hamburger ingyen 1 mellé',
    price: 300,
    category: ShopCategory.coupons,
    emoji: '🍔',
    color: Colors.orange,
    rarity: 'rare',
  ),
  ShopItem(
    id: 'coupon_cinema',
    name: 'Mozi -20%',
    description: '20% kedvezmény Cinema City',
    price: 250,
    category: ShopCategory.coupons,
    emoji: '🎬',
    color: Colors.deepPurple,
    rarity: 'rare',
  ),
  ShopItem(
    id: 'coupon_pizza',
    name: 'Pizza Hut -15%',
    description: '15% kedvezmény pizzára',
    price: 180,
    category: ShopCategory.coupons,
    emoji: '🍕',
    color: Colors.red,
    rarity: 'common',
  ),

  // ============ KIEGÉSZÍTŐK (avatarra) ============
  // Sapkák
  ShopItem(
    id: 'hat_cap',
    name: 'Baseball sapka',
    description: 'Cool baseball sapka',
    price: 100,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.hat,
    emoji: '🧢',
    color: Colors.blue,
    rarity: 'common',
  ),
  ShopItem(
    id: 'hat_top',
    name: 'Cilinder',
    description: 'Elegáns cilinder',
    price: 300,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.hat,
    emoji: '🎩',
    color: Colors.black,
    rarity: 'epic',
  ),
  ShopItem(
    id: 'hat_crown',
    name: 'Korona',
    description: 'Király vagy!',
    price: 1000,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.hat,
    emoji: '👑',
    color: Colors.amber,
    rarity: 'legendary',
  ),
  // Felsők
  ShopItem(
    id: 'shirt_tshirt',
    name: 'Póló',
    description: 'Egyszerű pamut póló',
    price: 80,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.shirt,
    emoji: '👕',
    color: Colors.teal,
    rarity: 'common',
  ),
  ShopItem(
    id: 'shirt_hoodie',
    name: 'Pulcsi',
    description: 'Meleg, kényelmes pulcsi',
    price: 150,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.shirt,
    emoji: '🧥',
    color: Colors.grey,
    rarity: 'rare',
  ),
  ShopItem(
    id: 'shirt_suit',
    name: 'Öltöny',
    description: 'Elegáns öltöny',
    price: 500,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.shirt,
    emoji: '🤵',
    color: Colors.indigo,
    rarity: 'epic',
  ),
  // Nadrágok
  ShopItem(
    id: 'pants_jeans',
    name: 'Farmer',
    description: 'Klasszikus farmer',
    price: 120,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.pants,
    emoji: '👖',
    color: Colors.blue,
    rarity: 'common',
  ),
  ShopItem(
    id: 'pants_shorts',
    name: 'Rövidnadrág',
    description: 'Nyári rövidnadrág',
    price: 80,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.pants,
    emoji: '🩳',
    color: Colors.orange,
    rarity: 'common',
  ),
  // Cipők
  ShopItem(
    id: 'shoes_sneaker',
    name: 'Sportcipő',
    description: 'Kényelmes sportcipő',
    price: 100,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.shoes,
    emoji: '👟',
    color: Colors.white,
    rarity: 'common',
  ),
  ShopItem(
    id: 'shoes_boots',
    name: 'Bakancs',
    description: 'Kemény bakancs',
    price: 200,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.shoes,
    emoji: '🥾',
    color: Colors.brown,
    rarity: 'rare',
  ),
  // Szemüveg
  ShopItem(
    id: 'glasses_sun',
    name: 'Napszemüveg',
    description: 'Cool napszemüveg',
    price: 150,
    category: ShopCategory.accessories,
    accessoryType: AccessoryType.glasses,
    emoji: '🕶️',
    color: Colors.black87,
    rarity: 'rare',
  ),

  // ============ VICCES JUTALMAK ============
  ShopItem(
    id: 'pet_pig',
    name: 'Malac',
    description: 'Aranyos kis malac',
    price: 200,
    category: ShopCategory.collectibles,
    emoji: '🐷',
    color: Colors.pink,
    rarity: 'rare',
  ),
  ShopItem(
    id: 'pet_dog',
    name: 'Kutyus',
    description: 'Hűséges barát',
    price: 250,
    category: ShopCategory.collectibles,
    emoji: '🐶',
    color: Colors.brown,
    rarity: 'rare',
  ),
  ShopItem(
    id: 'pet_cat',
    name: 'Cica',
    description: 'Lusta de szerethető',
    price: 250,
    category: ShopCategory.collectibles,
    emoji: '🐱',
    color: Colors.orange,
    rarity: 'rare',
  ),
  ShopItem(
    id: 'item_beer',
    name: 'Sör',
    description: 'Egészségedre! 🍻',
    price: 50,
    category: ShopCategory.collectibles,
    emoji: '🍺',
    color: Colors.amber,
    rarity: 'common',
  ),
  ShopItem(
    id: 'item_coffee',
    name: 'Kávé',
    description: 'Reggeli kávé',
    price: 50,
    category: ShopCategory.collectibles,
    emoji: '☕',
    color: Colors.brown,
    rarity: 'common',
  ),
  ShopItem(
    id: 'sticker_handshake',
    name: 'Kézfogás matrica',
    description: '🤝 matrica gyűjteményed',
    price: 30,
    category: ShopCategory.collectibles,
    emoji: '🤝',
    color: Colors.blue,
    rarity: 'common',
  ),
  ShopItem(
    id: 'item_pizza',
    name: 'Pizza',
    description: 'Egy szelet pizza',
    price: 80,
    category: ShopCategory.collectibles,
    emoji: '🍕',
    color: Colors.red,
    rarity: 'common',
  ),
  ShopItem(
    id: 'item_diamond',
    name: 'Gyémánt',
    description: 'Ritka és értékes! 💎',
    price: 1500,
    category: ShopCategory.collectibles,
    emoji: '💎',
    color: Colors.cyan,
    rarity: 'legendary',
  ),
  ShopItem(
    id: 'item_unicorn',
    name: 'Unikornis',
    description: 'Mágikus barát',
    price: 800,
    category: ShopCategory.collectibles,
    emoji: '🦄',
    color: Colors.purpleAccent,
    rarity: 'epic',
  ),
];

// Színek a ritkasághoz
Color rarityColor(String? rarity) {
  switch (rarity) {
    case 'legendary':
      return Colors.amber;
    case 'epic':
      return Colors.purple;
    case 'rare':
      return Colors.blue;
    case 'common':
    default:
      return Colors.grey;
  }
}

String rarityName(String? rarity) {
  switch (rarity) {
    case 'legendary':
      return 'Legendás';
    case 'epic':
      return 'Epikus';
    case 'rare':
      return 'Ritka';
    case 'common':
    default:
      return 'Általános';
  }
}
