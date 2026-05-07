import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Friend {
  final String id;
  final String name;
  final LatLng position;
  final Color color;
  final int streak;
  final String lastSeen; // pl. "2 perce"
  final String location; // pl. "Parlament"
  final bool isOnline;

  Friend({
    required this.id,
    required this.name,
    required this.position,
    required this.color,
    this.streak = 0,
    this.lastSeen = '',
    this.location = '',
    this.isOnline = false,
  });
}

// Demo barátok (később Firebase-ből jön)
final List<Friend> demoFriends = [
  Friend(
    id: '1',
    name: 'Anna',
    position: const LatLng(47.5079, 19.0452),
    color: Colors.pink,
    streak: 12,
    lastSeen: '2 perce',
    location: 'Nyugati tér',
    isOnline: true,
  ),
  Friend(
    id: '2',
    name: 'Béla',
    position: const LatLng(47.4929, 19.0502),
    color: Colors.blue,
    streak: 5,
    lastSeen: '15 perce',
    location: 'Astoria',
    isOnline: true,
  ),
  Friend(
    id: '3',
    name: 'Cili',
    position: const LatLng(47.5029, 19.0352),
    color: Colors.green,
    streak: 30,
    lastSeen: '1 órája',
    location: 'Margitsziget',
    isOnline: false,
  ),
];
