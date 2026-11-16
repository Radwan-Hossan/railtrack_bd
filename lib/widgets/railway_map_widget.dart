import 'dart:math';
import 'package:flutter/material.dart';
import '../models/train.dart';
import '../models/station.dart';
import '../models/route_segment.dart';
import '../data/bangladesh_railway_data.dart';
import '../constants/app_colors.dart';

class RailwayMapWidget extends StatefulWidget {
  final Train train;
  final String languageCode;
  final bool isSatelliteMode;
  final Function(Station)? onStationTap;

  const RailwayMapWidget({
    super.key,
    required this.train,
    required this.languageCode,
    this.isSatelliteMode = false,
    this.onStationTap,
  });

  @override
  State<RailwayMapWidget> createState() => RailwayMapWidgetState();
}

class RailwayMapWidgetState extends State<RailwayMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Viewport transforms (Pan & Zoom)
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  Offset _basePanOffset = Offset.zero;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void recenter() {
    setState(() {
      _panOffset = Offset.zero;
      _scale = 1.0;
    });
  }

  void zoomIn() {
    setState(() {
      _scale = (_scale * 1.25).clamp(0.6, 4.0);
    });
  }

  void zoomOut() {
    setState(() {
      _scale = (_scale / 1.25).clamp(0.6, 4.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    RailwayRoute route = BangladeshRailwayData.dhakaChittagongRoute;
    if (widget.train.destination.id == 'SYL' || widget.train.origin.id == 'SYL') {
      route = BangladeshRailwayData.dhakaSylhetRoute;
    } else if (widget.train.destination.id == 'RAJ' || widget.train.origin.id == 'RAJ') {
      route = BangladeshRailwayData.dhakaRajshahiRoute;
    }

    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _scale;
        _basePanOffset = _panOffset - details.focalPoint;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_baseScale * details.scale).clamp(0.6, 4.0);
          _panOffset = _basePanOffset + details.focalPoint;
        });
      },
      child: ClipRRect(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _MapCanvasPainter(
                train: widget.train,
                route: route,
                stations: BangladeshRailwayData.allStations,
                languageCode: widget.languageCode,
                isSatellite: widget.isSatelliteMode,
                pulseScale: _pulseAnimation.value,
                panOffset: _panOffset,
                zoomScale: _scale,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  final Train train;
  final RailwayRoute route;
  final List<Station> stations;
  final String languageCode;
  final bool isSatellite;
  final double pulseScale;
  final Offset panOffset;
  final double zoomScale;

  _MapCanvasPainter({
    required this.train,
    required this.route,
    required this.stations,
    required this.languageCode,
    required this.isSatellite,
    required this.pulseScale,
    required this.panOffset,
    required this.zoomScale,
  });

  // Bounding box for Bangladesh Railway Network
  static const double minLat = 22.0;
  static const double maxLat = 25.2;
  static const double minLng = 88.2;
  static const double maxLng = 92.2;

  Offset _geoToScreen(double lat, double lng, Size size) {
    // Project geographic coordinates into canvas pixels
    final normX = (lng - minLng) / (maxLng - minLng);
    final normY = 1.0 - ((lat - minLat) / (maxLat - minLat)); // Flip Y for canvas

    final baseCenterX = size.width * 0.5;
    final baseCenterY = size.height * 0.5;

    final rawX = normX * size.width;
    final rawY = normY * size.height;

    final scaledX = (rawX - baseCenterX) * zoomScale + baseCenterX + panOffset.dx;
    final scaledY = (rawY - baseCenterY) * zoomScale + baseCenterY + panOffset.dy;

    return Offset(scaledX, scaledY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background layer (Satellite dark earth or Vector night map)
    final bgPaint = Paint()
      ..color = isSatellite ? const Color(0xFF0F1B18) : AppColors.darkBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle grid lines to resemble MapLibre/GIS coordinates
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 1. Draw Railway Route Corridors (Double track ballast effect)
    final routePoints = route.coordinates.map((p) => _geoToScreen(p.latitude, p.longitude, size)).toList();
    if (routePoints.length >= 2) {
      // Outer track ballast
      final ballastPaint = Paint()
        ..color = AppColors.trackBed
        ..strokeWidth = 6.0 * zoomScale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final ballastPath = Path()..moveTo(routePoints[0].dx, routePoints[0].dy);
      for (int i = 1; i < routePoints.length; i++) {
        ballastPath.lineTo(routePoints[i].dx, routePoints[i].dy);
      }
      canvas.drawPath(ballastPath, ballastPaint);

      // Active illuminated track
      final activeTrackPaint = Paint()
        ..color = AppColors.trackActive.withValues(alpha: 0.85)
        ..strokeWidth = 3.0 * zoomScale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(ballastPath, activeTrackPaint);
    }

    // 2. Draw Stations along the network
    for (final station in stations) {
      final sPos = _geoToScreen(station.latitude, station.longitude, size);

      // Station Halo
      final haloPaint = Paint()
        ..color = AppColors.goldAccent.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sPos, 8.0 * zoomScale, haloPaint);

      // Station Center Node
      final nodePaint = Paint()
        ..color = AppColors.goldAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sPos, 4.0 * zoomScale, nodePaint);

      final nodeBorderPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(sPos, 4.0 * zoomScale, nodeBorderPaint);

      // Station Name Label
      final textSpan = TextSpan(
        text: station.localizedName(languageCode),
        style: TextStyle(
          color: Colors.white70,
          fontSize: (10.0 * zoomScale).clamp(8.0, 13.0),
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(sPos.dx + 8, sPos.dy - 6));
    }

    // 3. Draw Moving Train Marker with Live Bearing & Pulse
    final trainPos = _geoToScreen(
      train.currentPosition.latitude,
      train.currentPosition.longitude,
      size,
    );

    // Glowing Pulse Ripple
    final pulsePaint = Paint()
      ..color = AppColors.statusLive.withValues(alpha: (1.5 - pulseScale).clamp(0.0, 0.5))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(trainPos, 18.0 * pulseScale * zoomScale, pulsePaint);

    // Train Marker Body
    final trainBodyPaint = Paint()
      ..color = AppColors.emeraldAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(trainPos, 9.0 * zoomScale, trainBodyPaint);

    final trainBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(trainPos, 9.0 * zoomScale, trainBorderPaint);

    // Train Directional Arrow
    final rad = (train.currentPosition.bearing - 90) * pi / 180;
    final arrowLength = 12.0 * zoomScale;
    final tip = Offset(trainPos.dx + cos(rad) * arrowLength, trainPos.dy + sin(rad) * arrowLength);
    final arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(trainPos, tip, arrowPaint);

    // Floating Train Label Badge on Map
    final labelSpan = TextSpan(
      text: '${train.trainNumber} • ${train.currentSpeedKmh.toStringAsFixed(0)} km/h',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final labelPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromLTWH(
      trainPos.dx - labelPainter.width / 2 - 6,
      trainPos.dy - 28 * zoomScale,
      labelPainter.width + 12,
      18,
    );
    final badgePaint = Paint()..color = AppColors.emeraldDark.withValues(alpha: 0.9);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(6)), badgePaint);
    labelPainter.paint(canvas, Offset(badgeRect.left + 6, badgeRect.top + 2));
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.train != train ||
        oldDelegate.pulseScale != pulseScale ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.zoomScale != zoomScale ||
        oldDelegate.isSatellite != isSatellite;
  }
}
