class LatLngPoint {
  final double latitude;
  final double longitude;

  const LatLngPoint(this.latitude, this.longitude);

  Map<String, double> toJson() => {'lat': latitude, 'lng': longitude};
}

class RailwayRoute {
  final String id;
  final String routeName;
  final List<LatLngPoint> coordinates;
  final double totalDistanceKm;

  const RailwayRoute({
    required this.id,
    required this.routeName,
    required this.coordinates,
    required this.totalDistanceKm,
  });
}
