import 'package:flutter/material.dart';

class StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
