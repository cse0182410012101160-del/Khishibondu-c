import 'package:equatable/equatable.dart';

class QualityCheckItem extends Equatable {
  final String parameter;
  final String result;
  final String standard;
  final String status;

  const QualityCheckItem({
    required this.parameter,
    required this.result,
    required this.standard,
    required this.status,
  });

  factory QualityCheckItem.fromJson(Map<String, dynamic> json) {
    return QualityCheckItem(
      parameter: json['parameter'] ?? '',
      result: json['result'] ?? '',
      standard: json['standard'] ?? '',
      status: json['status'] ?? 'PASSED',
    );
  }

  Map<String, dynamic> toJson() => {
        'parameter': parameter,
        'result': result,
        'standard': standard,
        'status': status,
      };

  @override
  List<Object?> get props => [parameter, result, status];
}

class TraceabilityEntity extends Equatable {
  final String batchQrCode;
  final String verificationUrl;
  final String cropTitle;
  final String? cropTitleBn;
  final String category;
  final String grade;
  final bool organicCertified;
  final String harvestDate;
  final Map<String, dynamic> farmLocation;
  final Map<String, dynamic> farmerProfile;
  final List<QualityCheckItem> qualityChecks;

  const TraceabilityEntity({
    required this.batchQrCode,
    required this.verificationUrl,
    required this.cropTitle,
    this.cropTitleBn,
    required this.category,
    required this.grade,
    required this.organicCertified,
    required this.harvestDate,
    required this.farmLocation,
    required this.farmerProfile,
    required this.qualityChecks,
  });

  @override
  List<Object?> get props => [batchQrCode, cropTitle, harvestDate];
}

