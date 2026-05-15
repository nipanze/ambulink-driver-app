import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  StreamSubscription<Position>? _subscription;
  Position? _current;
  Position? get current => _current;

  double? get latitude  => _current?.latitude;
  double? get longitude => _current?.longitude;

  // Request permission and start tracking
  Future<bool> startTracking(int driverId) async {
    // Skip geolocator on Linux as it's not supported
    if (Platform.isLinux || Platform.isWindows) {
      debugPrint('Location tracking is not supported on this platform.');
      return true; // Return true to allow "Online" status without tracking
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update every 10m
      );

      _subscription = Geolocator.getPositionStream(locationSettings: settings)
          .listen((pos) {
        _current = pos;
        _pushToSupabase(driverId, pos);
        notifyListeners();
      });

      return true;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      return false;
    }
  }

  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _pushToSupabase(int driverId, Position pos) async {
    try {
      await _supabase.from('driver_locations').upsert({
        'driver_id':  driverId,
        'latitude':   pos.latitude,
        'longitude':  pos.longitude,
        'heading':    pos.heading,
        'speed_kmh':  (pos.speed * 3.6),
        'accuracy_m': pos.accuracy,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'driver_id');
    } catch (e) {
      debugPrint('GPS push error: $e');
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
