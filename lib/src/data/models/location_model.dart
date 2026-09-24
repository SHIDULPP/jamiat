class LocationDistrict {
  const LocationDistrict({
    required this.id,
    required this.name,
    this.state,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? state;
  final bool isActive;

  factory LocationDistrict.fromJson(Map<String, dynamic> json) {
    return LocationDistrict(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      state: json['state']?.toString(),
      isActive: json['is_active'] != false,
    );
  }
}

class LocationArea {
  const LocationArea({
    required this.id,
    required this.name,
    this.districtId,
    this.districtName,
    this.state,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? districtId;
  final String? districtName;
  final String? state;
  final bool isActive;

  factory LocationArea.fromJson(Map<String, dynamic> json) {
    final district = json['district'];
    String? districtId;
    String? districtName;

    if (district is Map) {
      districtId = (district['_id'] ?? district['id'])?.toString();
      districtName = district['name']?.toString();
    } else if (district != null) {
      districtId = district.toString();
    }

    return LocationArea(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      districtId: districtId,
      districtName: districtName,
      state: json['state']?.toString(),
      isActive: json['is_active'] != false,
    );
  }
}
