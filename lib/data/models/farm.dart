import 'package:flutter/foundation.dart';

enum SoilType { clay, loam, sandy, silt, peat, unknown }

extension SoilTypeX on SoilType {
  String get bangla {
    switch (this) {
      case SoilType.clay:
        return 'কর্দম মাটি';
      case SoilType.loam:
        return 'দোআঁশ মাটি';
      case SoilType.sandy:
        return 'বেলে মাটি';
      case SoilType.silt:
        return 'পলি মাটি';
      case SoilType.peat:
        return 'জৈব মাটি';
      case SoilType.unknown:
        return 'অজানা';
    }
  }

  String get key => name;
}

@immutable
class Farm {
  const Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.sizeAcres,
    required this.soilType,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String name;
  final String location;
  final double sizeAcres;
  final SoilType soilType;
  final String? notes;
  final DateTime? createdAt;

  Farm copyWith({
    String? name,
    String? location,
    double? sizeAcres,
    SoilType? soilType,
    String? notes,
  }) {
    return Farm(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      sizeAcres: sizeAcres ?? this.sizeAcres,
      soilType: soilType ?? this.soilType,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'sizeAcres': sizeAcres,
    'soilType': soilType.key,
    'notes': notes,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
    id: json['id'] as String,
    name: json['name'] as String,
    location: json['location'] as String,
    sizeAcres: (json['sizeAcres'] as num).toDouble(),
    soilType: SoilType.values.firstWhere(
      (e) => e.key == (json['soilType'] as String? ?? 'unknown'),
      orElse: () => SoilType.unknown,
    ),
    notes: json['notes'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );
}
