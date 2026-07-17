class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.status,
    required this.role,
    required this.isProfileComplete,
    this.name,
    this.email,
  });

  final String id;
  final String phone;
  final String status;
  final String role;
  final bool isProfileComplete;
  final String? name;
  final String? email;

  bool get canEnterApp => status == 'active' && isProfileComplete;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      status: (json['status'] ?? 'inactive').toString(),
      role: (json['role'] ?? 'normal_member').toString(),
      isProfileComplete: json['is_profile_complete'] == true,
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}
