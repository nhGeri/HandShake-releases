import 'package:flutter/foundation.dart';
import '../models/shop_item.dart';

class UserState extends ChangeNotifier {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;
  UserState._internal();

  // Felhasználó adatai
  String displayName = 'Te';
  int points = 1000;
  int currentStreak = 7;
  int totalHandshakes = 23;

  // 3D Avatar URL
  String? avatarUrl;

  // Beállítások
  bool shareLocation = true;
  bool showLastSeen = true;
  bool showCurrentLocation = true;

  // Megvásárolt itemek
  Set<String> ownedItems = {};

  // NFC-vel hozzáadott barátok
  List<String> nfcFriends = [];

  // Felvett kiegészítők
  String? equippedHat;
  String? equippedShirt;
  String? equippedPants;
  String? equippedShoes;
  String? equippedGlasses;

  void setAvatarUrl(String url) {
    avatarUrl = url;
    notifyListeners();
  }

  void buyItem(ShopItem item) {
    if (points >= item.price && !ownedItems.contains(item.id)) {
      points -= item.price;
      ownedItems.add(item.id);
      notifyListeners();
    }
  }

  void equipItem(ShopItem item) {
    if (!ownedItems.contains(item.id)) return;
    switch (item.accessoryType) {
      case AccessoryType.hat:
        equippedHat = equippedHat == item.id ? null : item.id;
        break;
      case AccessoryType.shirt:
        equippedShirt = equippedShirt == item.id ? null : item.id;
        break;
      case AccessoryType.pants:
        equippedPants = equippedPants == item.id ? null : item.id;
        break;
      case AccessoryType.shoes:
        equippedShoes = equippedShoes == item.id ? null : item.id;
        break;
      case AccessoryType.glasses:
        equippedGlasses = equippedGlasses == item.id ? null : item.id;
        break;
      case AccessoryType.none:
        break;
    }
    notifyListeners();
  }

  bool isEquipped(String itemId) {
    return equippedHat == itemId ||
        equippedShirt == itemId ||
        equippedPants == itemId ||
        equippedShoes == itemId ||
        equippedGlasses == itemId;
  }

  void addPoints(int amount) {
    points += amount;
    notifyListeners();
  }

  void addHandshake(String friendName) {
    totalHandshakes++;
    points += 10;
    currentStreak++;
    if (!nfcFriends.contains(friendName)) {
      nfcFriends.add(friendName);
    }
    notifyListeners();
  }

  void incrementStreak() {
    currentStreak++;
    notifyListeners();
  }

  void toggleShareLocation(bool value) {
    shareLocation = value;
    notifyListeners();
  }

  void toggleShowLastSeen(bool value) {
    showLastSeen = value;
    notifyListeners();
  }

  void toggleShowCurrentLocation(bool value) {
    showCurrentLocation = value;
    notifyListeners();
  }
}
