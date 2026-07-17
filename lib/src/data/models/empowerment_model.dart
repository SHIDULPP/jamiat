class EmpowermentProgramModel {
  const EmpowermentProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isBookmarked,
    required this.isApplied,
    this.image,
    this.startDate,
  });

  final String id;
  final String title;
  final String description;
  final bool isBookmarked;
  final bool isApplied;
  final String? image;
  final DateTime? startDate;

  factory EmpowermentProgramModel.fromJson(Map<String, dynamic> json) {
    return EmpowermentProgramModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isBookmarked: json['is_bookmarked'] == true,
      isApplied: json['is_applied'] == true,
      image: json['image']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
    );
  }
}
