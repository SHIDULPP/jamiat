import 'package:jamiat/src/data/models/campaign_model.dart';

class WelfareStatement {
  const WelfareStatement({
    required this.heading,
    required this.description,
  });

  final String heading;
  final String description;

  factory WelfareStatement.fromJson(Map<String, dynamic> json) {
    return WelfareStatement(
      heading: (json['heading'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

class WelfareImpactStat {
  const WelfareImpactStat({
    required this.title,
    required this.status,
  });

  final String title;
  final String status;

  factory WelfareImpactStat.fromJson(Map<String, dynamic> json) {
    return WelfareImpactStat(
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class WelfareServiceModel {
  const WelfareServiceModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.isActive,
    this.icon,
    this.accentColor,
    this.fullDescription,
    this.statements = const [],
    this.impactStatus = const [],
    this.targetLabel,
    this.targetYear,
    this.activeCampaignCount = 0,
    this.linkedCampaigns = const [],
  });

  final String id;
  final String name;
  final String shortDescription;
  final bool isActive;
  final String? icon;
  final String? accentColor;
  final String? fullDescription;
  final List<WelfareStatement> statements;
  final List<WelfareImpactStat> impactStatus;
  final String? targetLabel;
  final int? targetYear;
  final int activeCampaignCount;
  final List<CampaignModel> linkedCampaigns;

  factory WelfareServiceModel.fromJson(Map<String, dynamic> json) {
    final statementsRaw = json['statements'];
    final impactRaw = json['impact_status'];
    final campaignsRaw = json['linked_campaigns'];

    return WelfareServiceModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      shortDescription: (json['short_description'] ?? '').toString(),
      fullDescription: json['full_description']?.toString(),
      icon: json['icon']?.toString(),
      accentColor: json['accent_color']?.toString(),
      isActive: (json['status'] ?? 'active').toString() == 'active',
      statements: statementsRaw is List
          ? statementsRaw
                .whereType<Map>()
                .map(
                  (e) =>
                      WelfareStatement.fromJson(Map<String, dynamic>.from(e)),
                )
                .where((s) => s.heading.isNotEmpty)
                .toList()
          : const [],
      impactStatus: impactRaw is List
          ? impactRaw
                .whereType<Map>()
                .map(
                  (e) =>
                      WelfareImpactStat.fromJson(Map<String, dynamic>.from(e)),
                )
                .where((s) => s.title.isNotEmpty)
                .toList()
          : const [],
      targetLabel: json['target_label']?.toString(),
      targetYear: (json['target_year'] as num?)?.toInt(),
      activeCampaignCount:
          (json['active_campaign_count'] as num?)?.toInt() ?? 0,
      linkedCampaigns: campaignsRaw is List
          ? campaignsRaw
                .whereType<Map>()
                .map((e) => CampaignModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}
