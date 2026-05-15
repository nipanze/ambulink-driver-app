import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool         isActive;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF7F7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFFFCA5A5) : Colors.grey.shade100,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.red.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(children: [
            Text(_typeEmoji(booking.type), style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(booking.bookingRef,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12,
                        color: Colors.grey)),
                const SizedBox(height: 2),
                Row(children: [
                  _badge(booking.statusLabel, _statusColor(booking.status)),
                  if (booking.isPriority) ...[
                    const SizedBox(width: 6),
                    _badge('Priority', const Color(0xFFDC2626), light: false),
                  ],
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (booking.fareAmount != null)
                Text('UGX ${booking.fareAmount!.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDC2626),
                  ),
                ),
            ]),
          ]),

          const SizedBox(height: 10),

          // Pickup
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF16A34A)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                booking.pickupAddress ?? 'GPS location',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),

          // Destination
          if (booking.destinationName != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.local_hospital_outlined, size: 15, color: Color(0xFFDC2626)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  booking.destinationName!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],

          // Active actions hint
          if (isActive) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.touch_app, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('Tap to manage', style: TextStyle(color: Colors.white,
                    fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _badge(String label, Color color, {bool light = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: light ? color.withValues(alpha: 0.12) : color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: light ? color : Colors.white)),
    );
  }

  String _typeEmoji(String t) =>
      {'emergency': '🚨', 'scheduled': '📅', 'institutional': '🏥', 'highway': '🛣️'}[t] ?? '🚑';

  Color _statusColor(String s) {
    const m = {
      'requested': Color(0xFFD97706), 'assigned': Color(0xFF2563EB),
      'en_route': Color(0xFF7C3AED),  'at_scene': Color(0xFF9333EA),
      'transporting': Color(0xFFEA580C), 'completed': Color(0xFF16A34A),
      'cancelled': Color(0xFF6B7280),
    };
    return m[s] ?? Colors.grey;
  }
}
