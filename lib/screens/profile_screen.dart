import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthService>();
    final driver = context.watch<DriverService>();
    final d      = driver.driver;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Avatar + name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(children: [
              SizedBox(
                width: 90, height: 90,
                child: Image.asset('assets/images/icon.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 12),
              Text(auth.displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: d?.status == 'active' ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  d?.status.toUpperCase() ?? '—',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: d?.status == 'active' ? const Color(0xFF15803D) : Colors.grey,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Vehicle info
          if (d != null) ...[
            _section('Vehicle Information', [
              _tile('Plate Number', d.vehiclePlate, Icons.directions_car_outlined),
              _tile('Vehicle Type', d.vehicleType.toUpperCase(), Icons.local_shipping_outlined),
              _tile('Model', d.vehicleModel, Icons.info_outline),
              _tile('Color', d.vehicleColor, Icons.color_lens_outlined),
              _tile('Coverage Zone', d.coverageZone, Icons.map_outlined),
              _tile('Licence No.', d.licenseNumber, Icons.badge_outlined),
            ]),
            const SizedBox(height: 12),
            _section('Performance', [
              _tile('Total Trips', d.totalTrips.toString(), Icons.route_outlined),
              _tile('Average Rating', '⭐ ${d.averageRating.toStringAsFixed(2)}', Icons.star_outline),
            ]),
            const SizedBox(height: 12),
          ],

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('AmbuLink Driver App v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Text('Kampala International University © 2026',
              style: TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                  color: Colors.black54)),
        ),
        ...children,
      ],
    ),
  );

  Widget _tile(String label, String value, IconData icon) => ListTile(
    dense: true,
    leading: Icon(icon, size: 20, color: Colors.grey.shade500),
    title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    trailing: Text(value,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
  );
}
