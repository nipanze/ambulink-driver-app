import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driver_model.dart';
import '../models/booking_model.dart';

class DriverService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  DriverModel?   _driver;
  BookingModel?  _activeBooking;
  List<BookingModel> _history = [];
  bool           _loading = false;

  DriverModel?       get driver       => _driver;
  BookingModel?      get activeBooking => _activeBooking;
  List<BookingModel> get history      => _history;
  bool               get loading      => _loading;
  bool               get isOnline     => _driver?.isOnline ?? false;

  // Load driver profile from DB
  Future<void> loadDriver(int userId) async {
    _loading = true; notifyListeners();
    try {
      final data = await _supabase
          .from('drivers')
          .select('*')
          .eq('user_id', userId)
          .single();
      _driver = DriverModel.fromJson(data);
      await _loadActiveBooking();
    } catch (e) {
      debugPrint('loadDriver error: $e');
    } finally {
      _loading = false; notifyListeners();
    }
  }

  // Toggle online/offline
  Future<void> toggleOnline() async {
    if (_driver == null) return;
    final newStatus = !_driver!.isOnline;
    await _supabase
        .from('drivers')
        .update({'is_online': newStatus})
        .eq('id', _driver!.id);
    _driver = DriverModel.fromJson({..._driver!.toJson(), 'is_online': newStatus});
    notifyListeners();
  }

  // Load active booking (assigned/en_route/at_scene/transporting)
  Future<void> _loadActiveBooking() async {
    if (_driver == null) return;
    final data = await _supabase
        .from('bookings')
        .select('*')
        .eq('driver_id', _driver!.id)
        .inFilter('status', ['assigned','en_route','at_scene','transporting'])
        .maybeSingle();
    _activeBooking = data != null ? BookingModel.fromJson(data) : null;
    notifyListeners();
  }

  // Subscribe to new bookings assigned to this driver
  void subscribeToBookings() {
    if (_driver == null) return;
    _supabase
        .channel('driver-bookings-${_driver!.id}')
        .onPostgresChanges(
          event:  PostgresChangeEvent.all,
          schema: 'public',
          table:  'bookings',
          filter: PostgresChangeFilter(
            type:  PostgresChangeFilterType.eq,
            column:'driver_id',
            value: _driver!.id,
          ),
          callback: (payload) {
            _loadActiveBooking();
          },
        )
        .subscribe();
  }

  // Update booking status
  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    await _supabase
        .from('bookings')
        .update({
          'status':    newStatus,
          if (newStatus == 'en_route')     'assigned_at':  DateTime.now().toIso8601String(),
          if (newStatus == 'at_scene')     'pickup_at':    DateTime.now().toIso8601String(),
          if (newStatus == 'completed')    'dropoff_at':   DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
    await _loadActiveBooking();
  }

  // Load trip history
  Future<void> loadHistory() async {
    if (_driver == null) return;
    final data = await _supabase
        .from('bookings')
        .select('*')
        .eq('driver_id', _driver!.id)
        .eq('status', 'completed')
        .order('dropoff_at', ascending: false)
        .limit(30);
    _history = (data as List).map((j) => BookingModel.fromJson(j)).toList();
    notifyListeners();
  }
}
