import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../services/location_service.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final Completer<GoogleMapController> _mapCtrl = Completer();
  Set<Marker>    _markers   = {};
  final Set<Polyline>  _polylines = {};
  BookingModel?  _booking;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_booking != null) return;
    _booking = ModalRoute.of(context)?.settings.arguments as BookingModel?;
    if (_booking != null) _buildMapElements();
  }

  void _buildMapElements() {
    if (_booking == null) return;
    final pickup = LatLng(_booking!.pickupLatitude, _booking!.pickupLongitude);

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          infoWindow: InfoWindow(
            title: 'Patient Pickup',
            snippet: _booking!.pickupAddress ?? 'Pickup location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        if (_booking!.destinationLatitude != null)
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(
              _booking!.destinationLatitude!,
              _booking!.destinationLongitude!,
            ),
            infoWindow: InfoWindow(
              title: _booking!.destinationName ?? 'Destination',
              snippet: _booking!.destinationAddress,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
      };
    });
  }

  Future<void> _centreOnPickup() async {
    if (_booking == null) return;
    final ctrl = await _mapCtrl.future;
    await ctrl.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(_booking!.pickupLatitude, _booking!.pickupLongitude), 15,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loc     = context.watch<LocationService>();
    final booking = _booking;

    final initialPos = booking != null
        ? LatLng(booking.pickupLatitude, booking.pickupLongitude)
        : const LatLng(0.3176, 32.5825); // Kampala default

    // Add driver marker if we have GPS
    Set<Marker> allMarkers = {..._markers};
    if (loc.latitude != null && loc.longitude != null) {
      allMarkers.add(Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(loc.latitude!, loc.longitude!),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: loc.current?.heading ?? 0,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(booking?.bookingRef ?? 'Navigation',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centreOnPickup,
          ),
        ],
      ),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: initialPos, zoom: 14),
          markers:    allMarkers,
          polylines:  _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (ctrl) { _mapCtrl.complete(ctrl); _centreOnPickup(); },
        ),

        // Info panel
        if (booking != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('📍', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Pickup Location',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                    Text(booking.pickupAddress ?? 'GPS location',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                  ])),
                ]),
                if (booking.destinationName != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('🏥', style: TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Destination',
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                      Text(booking.destinationName!,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                    ])),
                  ]),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Open in Google Maps'),
                    onPressed: () {
                      // In production: launch google maps URL
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Google Maps…')),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}
