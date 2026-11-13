import 'package:agro_bridge/features/traceability/domain/entities/traceability_entity.dart';

class TraceabilityModel extends TraceabilityEntity {
  const TraceabilityModel({
    required super.batchQrCode,
    required super.verificationUrl,
    required super.cropTitle,
    super.cropTitleBn,
    required super.category,
    required super.grade,
    required super.organicCertified,
    required super.harvestDate,
    required super.farmLocation,
    required super.farmerProfile,
    required super.qualityChecks,
  });

  factory TraceabilityModel.fromJson(Map<String, dynamic> json) {
    final prov = json['provenance'] ?? json;
    return TraceabilityModel(
      batchQrCode: json['batchQrCode'] ?? '',
      verificationUrl: json['verificationUrl'] ?? 'https://agro-bridge.bd/trace',
      cropTitle: prov['cropTitle'] ?? 'Harvest Produce',
      cropTitleBn: prov['cropTitleBn'],
      category: prov['category'] ?? 'Crop',
      grade: prov['grade'] ?? 'A',
      organicCertified: prov['organicCertified'] ?? false,
      harvestDate: prov['harvestDate'] ?? '2026-03-01',
      farmLocation: prov['farmLocation'] != null ? Map<String, dynamic>.from(prov['farmLocation']) : {},
      farmerProfile: prov['farmerProfile'] != null ? Map<String, dynamic>.from(prov['farmerProfile']) : {},
      qualityChecks: prov['qualityChecks'] != null
          ? (prov['qualityChecks'] as List).map((q) => QualityCheckItem.fromJson(q)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchQrCode': batchQrCode,
      'verificationUrl': verificationUrl,
      'cropTitle': cropTitle,
      'cropTitleBn': cropTitleBn,
      'category': category,
      'grade': grade,
      'organicCertified': organicCertified,
      'harvestDate': harvestDate,
      'farmLocation': farmLocation,
      'farmerProfile': farmerProfile,
      'qualityChecks': qualityChecks.map((q) => q.toJson()).toList(),
    };
  }
}

