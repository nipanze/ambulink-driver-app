class DriverModel {
  final int    id;
  final int    userId;
  final String licenseNumber;
  final String vehiclePlate;
  final String vehicleType;
  final String vehicleModel;
  final String vehicleColor;
  final String coverageZone;
  final String status;
  final bool   isOnline;
  final int    totalTrips;
  final double averageRating;

  const DriverModel({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.vehiclePlate,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.coverageZone,
    required this.status,
    required this.isOnline,
    required this.totalTrips,
    required this.averageRating,
  });

  factory DriverModel.fromJson(Map<String, dynamic> j) => DriverModel(
    id:             j['id'] as int,
    userId:         j['user_id'] as int,
    licenseNumber:  j['license_number'] ?? '',
    vehiclePlate:   j['vehicle_plate'] ?? '',
    vehicleType:    j['vehicle_type'] ?? 'basic',
    vehicleModel:   j['vehicle_model'] ?? '',
    vehicleColor:   j['vehicle_color'] ?? '',
    coverageZone:   j['coverage_zone'] ?? '',
    status:         j['status'] ?? 'pending',
    isOnline:       j['is_online'] as bool? ?? false,
    totalTrips:     j['total_trips'] as int? ?? 0,
    averageRating:  (j['average_rating'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'user_id':        userId,
    'license_number': licenseNumber,
    'vehicle_plate':  vehiclePlate,
    'vehicle_type':   vehicleType,
    'vehicle_model':  vehicleModel,
    'vehicle_color':  vehicleColor,
    'coverage_zone':  coverageZone,
    'status':         status,
    'is_online':      isOnline,
    'total_trips':    totalTrips,
    'average_rating': averageRating,
  };
}
