class EventPerson {
  const EventPerson({
    required this.name,
    this.designation,
    this.image,
  });

  final String name;
  final String? designation;
  final String? image;

  factory EventPerson.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ?? json['profile_image'] ?? json['photo'];
    final image = rawImage?.toString().trim();
    return EventPerson(
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

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final guestsRaw = json['guests'];
    final coordinatorsRaw = json['coordinators'];

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
      guests: guestsRaw is List
          ? guestsRaw
                .map(
                  (e) => e is Map
                      ? EventPerson.fromJson(Map<String, dynamic>.from(e))
                      : null,
                )
                .whereType<EventPerson>()
                .where((p) => p.name.isNotEmpty)
                .toList()
          : const [],
      coordinators: coordinatorsRaw is List
          ? coordinatorsRaw
                .map(
                  (e) => e is Map
                      ? EventPerson.fromJson(Map<String, dynamic>.from(e))
                      : null,
                )
                .whereType<EventPerson>()
                .where((p) => p.name.isNotEmpty)
                .toList()
          : const [],
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
