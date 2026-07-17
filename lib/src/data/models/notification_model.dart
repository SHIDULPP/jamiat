class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.subject,
    required this.content,
    required this.isRead,
    this.image,
    this.link,
    this.createdAt,
  });

  final String id;
  final String subject;
  final String content;
  final bool isRead;
  final String? image;
  final String? link;
  final DateTime? createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      isRead: json['read'] == true || json['is_read'] == true,
      image: json['image']?.toString(),
      link: json['link']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
