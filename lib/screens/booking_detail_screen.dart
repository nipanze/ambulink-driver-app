import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../services/driver_service.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = ModalRoute.of(context)!.settings.arguments as BookingModel;
    final driver  = context.watch<DriverService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(booking.bookingRef,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 15)),
        actions: [
          if (booking.isActive)
            IconButton(
              icon: const Icon(Icons.navigation_outlined),
              tooltip: 'Navigate',
              onPressed: () => Navigator.pushNamed(context, '/navigate', arguments: booking),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Status + type badges
          Row(children: [
            _badge(booking.statusLabel, _statusColor(booking.status)),
            const SizedBox(width: 8),
            _badge(_typeLabel(booking.type), _typeColor(booking.type)),
            if (booking.isPriority) ...[
              const SizedBox(width: 8),
              _badge('⚡ Priority', const Color(0xFFDC2626), light: false),
            ],
          ]),
          const SizedBox(height: 20),

          // Pickup
          _infoCard(children: [
            _row('Pickup', booking.pickupAddress ?? 'GPS location',
                icon: Icons.location_on, color: const Color(0xFF16A34A)),
            if (booking.pickupLandmark != null)
              _row('Landmark', booking.pickupLandmark!, icon: Icons.place_outlined),
            _row('Coordinates',
                '${booking.pickupLatitude.toStringAsFixed(5)}, ${booking.pickupLongitude.toStringAsFixed(5)}',
                icon: Icons.gps_fixed, small: true),
          ]),
          const SizedBox(height: 12),

          // Destination
          if (booking.destinationName != null)
            _infoCard(children: [
              _row('Destination', booking.destinationName!,
                  icon: Icons.local_hospital_outlined, color: const Color(0xFFDC2626)),
              if (booking.destinationAddress != null)
                _row('Address', booking.destinationAddress!, icon: Icons.map_outlined),
            ]),
          if (booking.destinationName != null) const SizedBox(height: 12),

          // Notes
          if (booking.patientNotes != null)
            _infoCard(children: [
              _row('Patient Notes', booking.patientNotes!,
                  icon: Icons.notes_outlined, color: const Color(0xFFD97706)),
            ]),
          if (booking.patientNotes != null) const SizedBox(height: 12),

          // Highway info
          if (booking.roadCorridor != null)
            _infoCard(children: [
              _row('Road Corridor', booking.roadCorridor!.replaceAll('_', '–'),
                  icon: Icons.directions_car_outlined),
              if (booking.highwayLandmark != null)
                _row('Highway Landmark', booking.highwayLandmark!,
                    icon: Icons.signpost_outlined),
            ]),
          if (booking.roadCorridor != null) const SizedBox(height: 12),

          // Payment
          _infoCard(children: [
            _row('Fare', booking.fareAmount != null
                ? 'UGX ${booking.fareAmount!.toStringAsFixed(0)}'
                : 'Not set',
                icon: Icons.payments_outlined),
            _row('Payment', booking.paymentStatus.toUpperCase(),
                icon: Icons.credit_card_outlined),
          ]),
          const SizedBox(height: 24),

          // Action buttons
          if (booking.isActive) _buildActionButtons(context, booking, driver),
        ]),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, BookingModel booking, DriverService driver) {
    final Map<String, Map<String, dynamic>> nextActions = {
      'assigned':    {'label': 'Start Driving → En Route', 'next': 'en_route',    'color': const Color(0xFF2563EB)},
      'en_route':    {'label': 'Arrived at Scene',          'next': 'at_scene',    'color': const Color(0xFF7C3AED)},
      'at_scene':    {'label': 'Start Transporting',        'next': 'transporting','color': const Color(0xFFEA580C)},
      'transporting':{'label': '✅ Mark as Completed',       'next': 'completed',   'color': const Color(0xFF16A34A)},
    };

    final action = nextActions[booking.status];
    if (action == null) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: action['color'] as Color,
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Confirm Action'),
              content: Text('Update status to "${(action['next'] as String).replaceAll('_', ' ')}"?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
              ],
            ),
          );
          if (confirm == true) {
            await driver.updateBookingStatus(booking.id, action['next'] as String);
            if (context.mounted) {
              if (action['next'] == 'completed') {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              } else {
                Navigator.pop(context);
              }
            }
          }
        },
        child: Text(action['label'] as String),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        icon: const Icon(Icons.navigation_outlined),
        label: const Text('Open Navigation'),
        onPressed: () => Navigator.pushNamed(context, '/navigate', arguments: booking),
      ),
    ]);
  }

  Widget _badge(String label, Color color, {bool light = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: light ? color.withValues(alpha: 0.12) : color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: light ? color : Colors.white)),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _row(String label, String value,
      {IconData? icon, Color? color, bool small = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: color ?? Colors.grey.shade500),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500,
                fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(
                fontSize: small ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.grey.shade800)),
          ]),
        ),
      ]),
    );
  }

  Color _statusColor(String s) {
    const m = {
      'requested': Color(0xFFD97706), 'assigned': Color(0xFF2563EB),
      'en_route': Color(0xFF7C3AED),  'at_scene': Color(0xFF9333EA),
      'transporting': Color(0xFFEA580C), 'completed': Color(0xFF16A34A),
      'cancelled': Color(0xFF6B7280),
    };
    return m[s] ?? Colors.grey;
  }

  Color _typeColor(String t) {
    const m = {
      'emergency': Color(0xFFDC2626), 'scheduled': Color(0xFF2563EB),
      'institutional': Color(0xFF7C3AED), 'highway': Color(0xFFEA580C),
    };
    return m[t] ?? Colors.grey;
  }

  String _typeLabel(String t) {
    const m = {
      'emergency': '🚨 Emergency', 'scheduled': '📅 Scheduled',
      'institutional': '🏥 Institutional', 'highway': '🛣️ Highway',
    };
    return m[t] ?? t;
  }
}
