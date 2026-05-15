class BookingModel {
  final int     id;
  final String  bookingRef;
  final int     patientId;
  final int?    driverId;
  final String  type;
  final String  status;
  final double  pickupLatitude;
  final double  pickupLongitude;
  final String? pickupAddress;
  final String? pickupLandmark;
  final String? destinationName;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? destinationAddress;
  final String? scheduledAt;
  final bool    isPriority;
  final String? patientNotes;
  final String? roadCorridor;
  final String? highwayLandmark;
  final double? fareAmount;
  final String  paymentStatus;
  final String  createdAt;

  const BookingModel({
    required this.id,
    required this.bookingRef,
    required this.patientId,
    this.driverId,
    required this.type,
    required this.status,
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.pickupAddress,
    this.pickupLandmark,
    this.destinationName,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationAddress,
    this.scheduledAt,
    required this.isPriority,
    this.patientNotes,
    this.roadCorridor,
    this.highwayLandmark,
    this.fareAmount,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) => BookingModel(
    id:                   j['id'] as int,
    bookingRef:           j['booking_ref'] ?? '',
    patientId:            j['patient_id'] as int,
    driverId:             j['driver_id'] as int?,
    type:                 j['type'] ?? 'emergency',
    status:               j['status'] ?? 'requested',
    pickupLatitude:       (j['pickup_latitude'] as num).toDouble(),
    pickupLongitude:      (j['pickup_longitude'] as num).toDouble(),
    pickupAddress:        j['pickup_address'],
    pickupLandmark:       j['pickup_landmark'],
    destinationName:      j['destination_name'],
    destinationLatitude:  (j['destination_latitude'] as num?)?.toDouble(),
    destinationLongitude: (j['destination_longitude'] as num?)?.toDouble(),
    destinationAddress:   j['destination_address'],
    scheduledAt:          j['scheduled_at'],
    isPriority:           j['is_priority'] as bool? ?? false,
    patientNotes:         j['patient_notes'],
    roadCorridor:         j['road_corridor'],
    highwayLandmark:      j['highway_landmark'],
    fareAmount:           (j['fare_amount'] as num?)?.toDouble(),
    paymentStatus:        j['payment_status'] ?? 'unpaid',
    createdAt:            j['created_at'] ?? '',
  );

  // Friendly status labels
  String get statusLabel {
    const labels = {
      'requested':   'Requested',
      'assigned':    'Assigned',
      'en_route':    'En Route',
      'at_scene':    'At Scene',
      'transporting':'Transporting',
      'completed':   'Completed',
      'cancelled':   'Cancelled',
      'expired':     'Expired',
    };
    return labels[status] ?? status;
  }

  bool get isActive => ['assigned','en_route','at_scene','transporting'].contains(status);
}
