import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: _avatarColor,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: _avatarColor,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color get _avatarColor {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
      const Color(0xFFE65100),
      const Color(0xFF00695C),
      const Color(0xFF283593),
      const Color(0xFF558B2F),
      const Color(0xFF4527A0),
    ];
    final index = name.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
    return colors[index];
  }
}
