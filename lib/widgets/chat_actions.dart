import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // optional for better icons

class ChatActions extends StatelessWidget {
  final VoidCallback? onCopy;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onRegenerate;

  const ChatActions({
    super.key,
    this.onCopy,
    this.onLike,
    this.onDislike,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.grey[700];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconButton(Icons.copy_rounded, onCopy, iconColor),
          const SizedBox(width: 16),
          _iconButton(Icons.thumb_up_alt_outlined, onLike, iconColor),
          const SizedBox(width: 16),
          _iconButton(Icons.thumb_down_alt_outlined, onDislike, iconColor),
          const SizedBox(width: 16),
          _iconButton(Icons.refresh_rounded, onRegenerate, iconColor),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback? onTap, Color? color) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
