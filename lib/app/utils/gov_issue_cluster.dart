import 'package:app/app/models/complaint_model.dart';

/// Suggested government cluster codes for routing complaints (Egypt-oriented).
abstract final class GovClusterCode {
  static const publicWorks = 'PUBLIC_WORKS';
  static const electricityAndLighting = 'ELECTRICITY_AND_LIGHTING';
  static const transportationAndTraffic = 'TRANSPORTATION_AND_TRAFFIC';
  static const sanitationAndCleanliness = 'SANITATION_AND_CLEANLINESS';
  static const waterAndSewage = 'WATER_AND_SEWAGE';
  static const gasAuthority = 'GAS_AUTHORITY';
  static const publicSafety = 'PUBLIC_SAFETY';
  static const parksAndGreenery = 'PARKS_AND_GREENERY';
  static const localMunicipality = 'LOCAL_MUNICIPALITY';

  /// Display order on the admin home screen.
  static const orderedCodes = <String>[
    publicWorks,
    electricityAndLighting,
    transportationAndTraffic,
    sanitationAndCleanliness,
    waterAndSewage,
    gasAuthority,
    publicSafety,
    parksAndGreenery,
    localMunicipality,
  ];
}

String _normalizeIssueKey(String raw) {
  return raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\s\-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_');
}

/// Maps a complaint to a government cluster using AI `issue_type` when present,
/// otherwise [Complaint.category], both normalized to snake_case tokens.
String resolveGovClusterCode(Complaint complaint) {
  final fromAi = complaint.aiAnalysis?.issueType?.trim();
  final raw = (fromAi != null && fromAi.isNotEmpty)
      ? fromAi
      : complaint.category;
  final primary = _normalizeIssueKey(raw);
  if (primary.isEmpty) {
    return GovClusterCode.localMunicipality;
  }

  final direct = _issueToCluster[primary];
  if (direct != null) return direct;

  for (final entry in _categoryKeywordClusters.entries) {
    if (primary.contains(entry.key)) {
      return entry.value;
    }
  }
  return GovClusterCode.localMunicipality;
}

const Map<String, String> _issueToCluster = {
  // Roads & Public Works
  'pothole': GovClusterCode.publicWorks,
  'road_crack': GovClusterCode.publicWorks,
  'sidewalk_damage': GovClusterCode.publicWorks,
  'manhole_issue': GovClusterCode.publicWorks,
  'road_flooding': GovClusterCode.publicWorks,
  'road_marking_faded': GovClusterCode.publicWorks,
  'road_damage': GovClusterCode.publicWorks,
  'roads': GovClusterCode.publicWorks,

  // Electricity & street lighting
  'street_light_out': GovClusterCode.electricityAndLighting,
  'street_light_damaged': GovClusterCode.electricityAndLighting,
  'exposed_wires': GovClusterCode.electricityAndLighting,

  // Traffic
  'traffic_light_malfunction': GovClusterCode.transportationAndTraffic,
  'traffic_sign_damaged': GovClusterCode.transportationAndTraffic,

  // Sanitation
  'garbage_overflow': GovClusterCode.sanitationAndCleanliness,
  'illegal_dumping': GovClusterCode.sanitationAndCleanliness,
  'broken_glass': GovClusterCode.sanitationAndCleanliness,

  // Water & sewage
  'water_leak': GovClusterCode.waterAndSewage,
  'sewer_backup': GovClusterCode.waterAndSewage,

  // Gas
  'gas_leak': GovClusterCode.gasAuthority,

  // Urban safety
  'dangerous_structure': GovClusterCode.publicSafety,

  // Parks
  'dead_tree': GovClusterCode.parksAndGreenery,
  'overgrown_vegetation': GovClusterCode.parksAndGreenery,
  'vegetation': GovClusterCode.parksAndGreenery,

  // Municipality / general
  'vandalism': GovClusterCode.localMunicipality,
  'other': GovClusterCode.localMunicipality,
};

/// Loose matching for legacy labels (e.g. "Roads", "Sanitation").
const Map<String, String> _categoryKeywordClusters = {
  'street_light': GovClusterCode.electricityAndLighting,
  'traffic': GovClusterCode.transportationAndTraffic,
  'garbage': GovClusterCode.sanitationAndCleanliness,
  'waste': GovClusterCode.sanitationAndCleanliness,
  'sanita': GovClusterCode.sanitationAndCleanliness,
  'water': GovClusterCode.waterAndSewage,
  'sewer': GovClusterCode.waterAndSewage,
  'gas': GovClusterCode.gasAuthority,
  'pothole': GovClusterCode.publicWorks,
  'road': GovClusterCode.publicWorks,
  'sidewalk': GovClusterCode.publicWorks,
  'manhole': GovClusterCode.publicWorks,
  'flood': GovClusterCode.publicWorks,
  'park': GovClusterCode.parksAndGreenery,
  'tree': GovClusterCode.parksAndGreenery,
  'vegetation': GovClusterCode.parksAndGreenery,
  'danger': GovClusterCode.publicSafety,
  'struct': GovClusterCode.publicSafety,
  'vandal': GovClusterCode.localMunicipality,
};
