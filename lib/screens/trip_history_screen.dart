import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_service.dart';
import '../widgets/booking_card.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});
  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<DriverService>().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverService>();

    // Summary stats
    final trips    = driver.history;
    final total    = trips.length;
    final revenue  = trips.fold<double>(0, (s, b) => s + (b.fareAmount ?? 0));
    final avgRating = driver.driver?.averageRating ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip History')),
      body: Column(children: [
        // Summary bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('$total', 'Trips'),
              _divider(),
              _stat('UGX ${(revenue / 1000).toStringAsFixed(0)}K', 'Earned'),
              _divider(),
              _stat(avgRating.toStringAsFixed(1), 'Avg Rating'),
            ],
          ),
        ),
        const Divider(height: 1),
        // List
        Expanded(
          child: driver.loading
              ? const Center(child: CircularProgressIndicator())
              : trips.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('📋', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text('No completed trips yet.',
                            style: TextStyle(color: Colors.grey)),
                      ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: trips.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BookingCard(
                          booking: trips[i],
                          isActive: false,
                          onTap: () => Navigator.pushNamed(
                              context, '/booking-detail', arguments: trips[i]),
                        ),
                      ),
                    ),
        ),
      ]),
    );
  }

  Widget _stat(String val, String label) => Column(children: [
    Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
    Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
  ]);

  Widget _divider() => Container(height: 36, width: 1, color: Colors.grey.shade200);
}
