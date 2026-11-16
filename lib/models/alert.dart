import 'dart:convert';

enum AlertType {
  stationProximity,
  delayWarning,
  emergency,
}

class TrainAlert {
  final String id;
  final String trainId;
  final String trainName;
  final String targetStationId;
  final String targetStationName;
  final String targetStationNameBn;
  final int notifyMinutesBefore;
  final double notifyDistanceKm;
  final AlertType type;
  final bool isActive;
  final bool isTriggered;
  final bool isDemo;
  final DateTime createdAt;
  final DateTime? triggeredAt;

  const TrainAlert({
    required this.id,
    required this.trainId,
    required this.trainName,
    required this.targetStationId,
    required this.targetStationName,
    this.targetStationNameBn = '',
    required this.notifyMinutesBefore,
    this.notifyDistanceKm = 10.0,
    this.type = AlertType.stationProximity,
    this.isActive = true,
    this.isTriggered = false,
    this.isDemo = true,
    required this.createdAt,
    this.triggeredAt,
  });

  TrainAlert copyWith({
    String? id,
    String? trainId,
    String? trainName,
    String? targetStationId,
    String? targetStationName,
    String? targetStationNameBn,
    int? notifyMinutesBefore,
    double? notifyDistanceKm,
    AlertType? type,
    bool? isActive,
    bool? isTriggered,
    bool? isDemo,
    DateTime? createdAt,
    DateTime? triggeredAt,
  }) {
    return TrainAlert(
      id: id ?? this.id,
      trainId: trainId ?? this.trainId,
      trainName: trainName ?? this.trainName,
      targetStationId: targetStationId ?? this.targetStationId,
      targetStationName: targetStationName ?? this.targetStationName,
      targetStationNameBn: targetStationNameBn ?? this.targetStationNameBn,
      notifyMinutesBefore: notifyMinutesBefore ?? this.notifyMinutesBefore,
      notifyDistanceKm: notifyDistanceKm ?? this.notifyDistanceKm,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      isTriggered: isTriggered ?? this.isTriggered,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainId': trainId,
      'trainName': trainName,
      'targetStationId': targetStationId,
      'targetStationName': targetStationName,
      'targetStationNameBn': targetStationNameBn,
      'notifyMinutesBefore': notifyMinutesBefore,
      'notifyDistanceKm': notifyDistanceKm,
      'type': type.index,
      'isActive': isActive,
      'isTriggered': isTriggered,
      'isDemo': isDemo,
      'createdAt': createdAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
    };
  }

  factory TrainAlert.fromMap(Map<String, dynamic> map) {
    return TrainAlert(
      id: map['id'] as String,
      trainId: map['trainId'] as String,
      trainName: map['trainName'] as String,
      targetStationId: map['targetStationId'] as String? ?? '',
      targetStationName: map['targetStationName'] as String,
      targetStationNameBn: map['targetStationNameBn'] as String? ?? '',
      notifyMinutesBefore: (map['notifyMinutesBefore'] as num).toInt(),
      notifyDistanceKm: (map['notifyDistanceKm'] as num?)?.toDouble() ?? 10.0,
      type: AlertType.values[(map['type'] as int?) ?? 0],
      isActive: map['isActive'] as bool? ?? true,
      isTriggered: map['isTriggered'] as bool? ?? false,
      isDemo: map['isDemo'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      triggeredAt: map['triggeredAt'] != null
          ? DateTime.parse(map['triggeredAt'] as String)
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TrainAlert.fromJson(String source) =>
      TrainAlert.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
