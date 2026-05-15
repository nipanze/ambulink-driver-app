import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../services/location_service.dart';
import '../widgets/booking_card.dart';
import '../widgets/stat_chip.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ds = context.read<DriverService>();
      ds.subscribeToBookings();
      ds.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthService>();
    final driver = context.watch<DriverService>();
    final loc    = context.watch<LocationService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(children: [
          if (_tab < 2) _buildHeader(auth, driver, loc),
          Expanded(
            child: IndexedStack(index: _tab, children: [
              _buildHome(driver),
              _buildHistory(driver),
              const ProfileScreen(),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthService auth, DriverService driver, LocationService loc) {
    final isOnline = driver.isOnline;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: Colors.white,
      child: Column(children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset('assets/images/icon.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back,', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(auth.displayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
          ),
          // Online toggle
          GestureDetector(
            onTap: () async {
              final ds = context.read<DriverService>();
              final ls = context.read<LocationService>();
              
              try {
                if (!isOnline && ds.driver != null) {
                  final started = await ls.startTracking(ds.driver!.id);
                  if (!started) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enable location services to go online')),
                      );
                    }
                    return;
                  }
                } else {
                  ls.stopTracking();
                }
                await ds.toggleOnline();
              } catch (e) {
                debugPrint('Toggle online error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating status: $e')),
                  );
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline ? const Color(0xFF16A34A) : Colors.grey.shade300,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? const Color(0xFF16A34A) : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 6),
                Text(isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isOnline ? const Color(0xFF15803D) : Colors.grey.shade600,
                    )),
              ]),
            ),
          ),
        ]),
        if (driver.driver != null) ...[
          const SizedBox(height: 14),
          Row(children: [
            StatChip(icon: '🚗', label: 'Plate', value: driver.driver!.vehiclePlate),
            const SizedBox(width: 8),
            StatChip(icon: '🏆', label: 'Trips', value: driver.driver!.totalTrips.toString()),
            const SizedBox(width: 8),
            StatChip(icon: '⭐', label: 'Rating', value: driver.driver!.averageRating.toStringAsFixed(1)),
          ]),
        ],
      ]),
    );
  }

  Widget _buildHome(DriverService driver) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Active booking
        if (driver.activeBooking != null) ...[
          _sectionTitle('Active Booking', icon: '🔴'),
          const SizedBox(height: 8),
          BookingCard(
            booking: driver.activeBooking!,
            isActive: true,
            onTap: () => Navigator.pushNamed(context, '/booking-detail',
                arguments: driver.activeBooking),
          ),
          const SizedBox(height: 20),
        ] else ...[
          // Waiting state
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(children: [
              driver.isOnline
                  ? Column(children: [
                      const Text('🟢', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('Waiting for bookings…',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('You are online and visible to patients.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      const SizedBox(width: 28, height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2,
                              color: Color(0xFFDC2626))),
                    ])
                  : Column(children: [
                      const Text('⚫', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('You are offline',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Toggle Online above to start receiving bookings.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          textAlign: TextAlign.center),
                    ]),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        // Recent trips
        if (driver.history.isNotEmpty) ...[
          _sectionTitle('Recent Trips', icon: '📋'),
          const SizedBox(height: 8),
          ...driver.history.take(3).map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BookingCard(booking: b, isActive: false,
                onTap: () => Navigator.pushNamed(context, '/booking-detail', arguments: b)),
          )),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/history'),
            child: const Text('View all trips →'),
          ),
        ],
      ]),
    );
  }

  Widget _buildHistory(DriverService driver) {
    return driver.history.isEmpty
        ? const Center(child: Text('No completed trips yet.', style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: driver.history.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BookingCard(
                booking: driver.history[i],
                isActive: false,
                onTap: () => Navigator.pushNamed(context, '/booking-detail',
                    arguments: driver.history[i]),
              ),
            ),
          );
  }

  Widget _sectionTitle(String t, {String icon = ''}) => Row(children: [
    if (icon.isNotEmpty) Text(icon, style: const TextStyle(fontSize: 16)),
    if (icon.isNotEmpty) const SizedBox(width: 6),
    Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
  ]);
}
