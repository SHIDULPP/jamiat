class EventPerson {
  const EventPerson({
    required this.name,
    this.id,
    this.designation,
    this.image,
  });

  final String? id;
  final String name;
  final String? designation;
  final String? image;

  factory EventPerson.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ?? json['profile_image'] ?? json['photo'];
    final image = rawImage?.toString().trim();
    return EventPerson(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: (json['name'] ?? '').toString().trim(),
      designation: json['designation']?.toString().trim(),
      image: (image == null || image.isEmpty || image == 'null') ? null : image,
    );
  }
}

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
    this.myTicketId,
    this.guests = const [],
    this.coordinators = const [],
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
  final String? myTicketId;
  final List<EventPerson> guests;
  final List<EventPerson> coordinators;

  bool isCoordinator(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return coordinators.any((c) => c.id == userId);
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final guestsRaw = json['guests'];
    final coordinatorsRaw = json['coordinators'];

    List<EventPerson> parsePeople(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .map((e) {
            if (e is Map) {
              return EventPerson.fromJson(Map<String, dynamic>.from(e));
            }
            // Unpopulated ObjectId string
            if (e != null) {
              return EventPerson(id: e.toString(), name: '');
            }
            return null;
          })
          .whereType<EventPerson>()
          .where((p) => p.id != null || p.name.isNotEmpty)
          .toList();
    }

    return EventModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      type: (json['event_type'] ?? json['type'] ?? 'Offline').toString(),
      isBookmarked: json['is_bookmarked'] == true,
      coverImage: json['cover_image']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      venue: json['venue']?.toString(),
      onlineLink: (json['link'] ?? json['online_link'])?.toString(),
      registrationEnabled: () {
        final required = json['registration_required'];
        if (required is bool) return required;
        final enabled = json['registration_enabled'];
        if (enabled is bool) return enabled;
        return true;
      }(),
      isRegistered: json['is_registered'] == true,
      myTicketId: json['my_ticket_id']?.toString(),
      guests: parsePeople(guestsRaw)
          .where((p) => p.name.isNotEmpty)
          .toList(),
      coordinators: parsePeople(coordinatorsRaw),
    );
  }
}

class EventTicketModel {
  const EventTicketModel({
    required this.id,
    required this.ticketCode,
    required this.status,
    this.displayStatus,
    this.qrImage,
    this.qrToken,
    this.eventId,
    this.eventTitle,
    this.eventDate,
    this.eventEndDate,
    this.venue,
    this.passType = 'General Entry Pass',
  });

  final String id;
  final String ticketCode;
  final String status;
  final String? displayStatus;
  final String? qrImage;
  final String? qrToken;
  final String? eventId;
  final String? eventTitle;
  final DateTime? eventDate;
  final DateTime? eventEndDate;
  final String? venue;
  final String passType;

  bool get isAttended =>
      displayStatus == 'attended' || status == 'attended';

  bool get isMissed =>
      displayStatus == 'missed' || status == 'missed';

  factory EventTicketModel.fromJson(Map<String, dynamic> json) {
    final event = json['event'];
    final eventMap = event is Map
        ? Map<String, dynamic>.from(event)
        : <String, dynamic>{};

    return EventTicketModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ticketCode: (json['ticket_code'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      displayStatus: json['display_status']?.toString(),
      qrImage: json['qr_image']?.toString(),
      qrToken: json['qr_token']?.toString(),
      eventId: (eventMap['_id'] ?? eventMap['id'])?.toString(),
      eventTitle: eventMap['title']?.toString(),
      eventDate: eventMap['start_date'] != null
          ? DateTime.tryParse(eventMap['start_date'].toString())
          : null,
      eventEndDate: eventMap['end_date'] != null
          ? DateTime.tryParse(eventMap['end_date'].toString())
          : null,
      venue: eventMap['venue']?.toString(),
      passType: (json['pass_type'] ?? 'General Entry Pass').toString(),
    );
  }
}

class EventScanResult {
  const EventScanResult({
    required this.alreadyAttended,
    required this.ticketCode,
    this.attendedAt,
    this.attendeeName,
    this.eventTitle,
    this.message,
  });

  final bool alreadyAttended;
  final String ticketCode;
  final DateTime? attendedAt;
  final String? attendeeName;
  final String? eventTitle;
  final String? message;

  factory EventScanResult.fromJson(
    Map<String, dynamic> json, {
    String? message,
  }) {
    final user = json['user'];
    final userMap = user is Map
        ? Map<String, dynamic>.from(user)
        : <String, dynamic>{};
    final event = json['event'];
    final eventMap = event is Map
        ? Map<String, dynamic>.from(event)
        : <String, dynamic>{};

    return EventScanResult(
      alreadyAttended: json['already_attended'] == true,
      ticketCode: (json['ticket_code'] ?? '').toString(),
      attendedAt: json['attended_at'] != null
          ? DateTime.tryParse(json['attended_at'].toString())
          : null,
      attendeeName: userMap['name']?.toString(),
      eventTitle: eventMap['title']?.toString(),
      message: message,
    );
  }
}
