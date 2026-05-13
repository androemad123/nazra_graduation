import 'package:flutter/material.dart';

import 'package:app/app/utils/gov_issue_cluster.dart';
import 'package:app/generated/l10n.dart';

String govClusterTitle(S s, String code) {
  switch (code) {
    case GovClusterCode.publicWorks:
      return s.govClusterPublicWorksTitle;
    case GovClusterCode.electricityAndLighting:
      return s.govClusterElectricityTitle;
    case GovClusterCode.transportationAndTraffic:
      return s.govClusterTrafficTitle;
    case GovClusterCode.sanitationAndCleanliness:
      return s.govClusterSanitationTitle;
    case GovClusterCode.waterAndSewage:
      return s.govClusterWaterTitle;
    case GovClusterCode.gasAuthority:
      return s.govClusterGasTitle;
    case GovClusterCode.publicSafety:
      return s.govClusterSafetyTitle;
    case GovClusterCode.parksAndGreenery:
      return s.govClusterParksTitle;
    case GovClusterCode.localMunicipality:
      return s.govClusterMunicipalityTitle;
    default:
      return s.govClusterMunicipalityTitle;
  }
}

String govClusterSubtitle(S s, String code) {
  switch (code) {
    case GovClusterCode.publicWorks:
      return s.govClusterPublicWorksSubtitle;
    case GovClusterCode.electricityAndLighting:
      return s.govClusterElectricitySubtitle;
    case GovClusterCode.transportationAndTraffic:
      return s.govClusterTrafficSubtitle;
    case GovClusterCode.sanitationAndCleanliness:
      return s.govClusterSanitationSubtitle;
    case GovClusterCode.waterAndSewage:
      return s.govClusterWaterSubtitle;
    case GovClusterCode.gasAuthority:
      return s.govClusterGasSubtitle;
    case GovClusterCode.publicSafety:
      return s.govClusterSafetySubtitle;
    case GovClusterCode.parksAndGreenery:
      return s.govClusterParksSubtitle;
    case GovClusterCode.localMunicipality:
      return s.govClusterMunicipalitySubtitle;
    default:
      return s.govClusterMunicipalitySubtitle;
  }
}

IconData govClusterIcon(String code) {
  switch (code) {
    case GovClusterCode.publicWorks:
      return Icons.construction_outlined;
    case GovClusterCode.electricityAndLighting:
      return Icons.electrical_services_outlined;
    case GovClusterCode.transportationAndTraffic:
      return Icons.traffic_outlined;
    case GovClusterCode.sanitationAndCleanliness:
      return Icons.delete_outline_rounded;
    case GovClusterCode.waterAndSewage:
      return Icons.water_damage_outlined;
    case GovClusterCode.gasAuthority:
      return Icons.local_fire_department_outlined;
    case GovClusterCode.publicSafety:
      return Icons.health_and_safety_outlined;
    case GovClusterCode.parksAndGreenery:
      return Icons.park_outlined;
    case GovClusterCode.localMunicipality:
      return Icons.location_city_outlined;
    default:
      return Icons.folder_open_outlined;
  }
}

Color govClusterAccent(String code) {
  switch (code) {
    case GovClusterCode.publicWorks:
      return const Color(0xFF6B5B4F);
    case GovClusterCode.electricityAndLighting:
      return const Color(0xFFC9A227);
    case GovClusterCode.transportationAndTraffic:
      return const Color(0xFF2E6BA6);
    case GovClusterCode.sanitationAndCleanliness:
      return const Color(0xFF2E7D5A);
    case GovClusterCode.waterAndSewage:
      return const Color(0xFF1565C0);
    case GovClusterCode.gasAuthority:
      return const Color(0xFFE65100);
    case GovClusterCode.publicSafety:
      return const Color(0xFFC62828);
    case GovClusterCode.parksAndGreenery:
      return const Color(0xFF558B2F);
    case GovClusterCode.localMunicipality:
      return const Color(0xFF5E35B1);
    default:
      return const Color(0xFF607D8B);
  }
}
