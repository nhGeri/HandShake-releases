import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendDetailScreen extends StatelessWidget {
  final Friend friend;

  const FriendDetailScreen({super.key, required this.friend});

  void _sendQuickMessage(BuildContext context, String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Üzenet elküldve ${friend.name}-nak: "$message"'),
        backgroundColor: friend.color,
        duration: const Duration(seconds: 2),
      ),
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profilkép
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: friend.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: friend.color.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 60),
                  ),
                  if (friend.isOnline)
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0A0E21), width: 3),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Név
              Text(
                friend.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Lokáció + utoljára látva
              if (friend.location.isNotEmpty)
                Text(
                  '📍 ${friend.location} • ${friend.lastSeen}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              const SizedBox(height: 24),
              // Streak badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, Colors.red],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      '${friend.streak} napos streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Divider(color: Colors.white24),
              const SizedBox(height: 16),

              const Text(
                'Gyors üzenetek',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Gyors üzenet gombok
              _quickMessageButton(context, '👋 Tali?', '👋 Tali?'),
              const SizedBox(height: 12),
              _quickMessageButton(context, '🤝 Összefutunk, közelben vagyok!', '🤝 Összefutunk, közelben vagyok!'),
              const SizedBox(height: 12),
              _quickMessageButton(context, '☕ Kávé?', '☕ Kávé?'),
              const SizedBox(height: 12),
              _quickMessageButton(context, '🍻 Sör?', '🍻 Sör?'),

              const Spacer(),

              // Teljes chat gomb
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat funkció hamarosan!')),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Teljes chat megnyitása'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickMessageButton(BuildContext context, String label, String message) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _sendQuickMessage(context, message),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: friend.color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: TextStyle(color: friend.color, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
