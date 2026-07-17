class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isBookmarked,
    this.coverImage,
    this.startDate,
    this.endDate,
    this.venue,
    this.onlineLink,
    this.registrationEnabled,
    this.isRegistered,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final bool isBookmarked;
  final String? coverImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? venue;
  final String? onlineLink;
  final bool? registrationEnabled;
  final bool? isRegistered;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      type: (json['type'] ?? 'Offline').toString(),
      isBookmarked: json['is_bookmarked'] == true,
      coverImage: json['cover_image']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      venue: json['venue']?.toString(),
      onlineLink: json['online_link']?.toString(),
      registrationEnabled: json['registration_enabled'] == true,
      isRegistered: json['is_registered'] == true,
    );
  }
}

class EventTicketModel {
  const EventTicketModel({
    required this.id,
    required this.ticketCode,
    required this.status,
    this.qrImage,
    this.eventTitle,
    this.eventDate,
    this.venue,
  });

  final String id;
  final String ticketCode;
  final String status;
  final String? qrImage;
  final String? eventTitle;
  final String? eventDate;
  final String? venue;

  factory EventTicketModel.fromJson(Map<String, dynamic> json) {
    final event = json['event'];
    return EventTicketModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ticketCode: (json['ticket_code'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      qrImage: json['qr_image']?.toString(),
      eventTitle: event is Map ? event['title']?.toString() : null,
      eventDate: event is Map ? event['start_date']?.toString() : null,
      venue: event is Map ? event['venue']?.toString() : null,
    );
  }
}
