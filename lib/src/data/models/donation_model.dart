class DonationModel {
  const DonationModel({
    required this.id,
    required this.amount,
    required this.status,
    this.campaignId,
    this.campaignName,
    this.message,
    this.paidAt,
    this.receiptUrl,
  });

  final String id;
  final num amount;
  final String status;
  final String? campaignId;
  final String? campaignName;
  final String? message;
  final DateTime? paidAt;
  final String? receiptUrl;

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    final campaign = json['campaign'];
    String? campaignId;
    String? campaignName;
    if (campaign is Map) {
      campaignId = (campaign['_id'] ?? campaign['id'])?.toString();
      campaignName = campaign['title']?.toString();
    } else if (campaign != null) {
      campaignId = campaign.toString();
    }

    return DonationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      amount: json['amount'] ?? 0,
      status: (json['status'] ?? '').toString(),
      campaignId: campaignId ?? json['campaign_id']?.toString(),
      campaignName:
          campaignName ??
          json['campaign_name']?.toString() ??
          json['campaign_title']?.toString(),
      message: json['message']?.toString(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
      receiptUrl: json['receipt_url']?.toString(),
    );
  }
}

class DonationHistorySummary {
  const DonationHistorySummary({
    required this.totalDonated,
    required this.participatedCampaigns,
    required this.totalPayments,
  });

  final num totalDonated;
  final int participatedCampaigns;
  final int totalPayments;

  factory DonationHistorySummary.fromJson(
    Map<String, dynamic> json, {
    int totalPayments = 0,
  }) {
    return DonationHistorySummary(
      totalDonated: json['total_donated'] ?? 0,
      participatedCampaigns:
          (json['participated_campaigns'] as num?)?.toInt() ?? 0,
      totalPayments: (json['total_payments'] as num?)?.toInt() ?? totalPayments,
    );
  }
}

class DonationCreateResult {
  const DonationCreateResult({
    required this.donationId,
    required this.razorpayOrderId,
    required this.razorpayKeyId,
    required this.amount,
    required this.currency,
  });

  final String donationId;
  final String razorpayOrderId;
  final String razorpayKeyId;
  final num amount;
  final String currency;

  factory DonationCreateResult.fromJson(Map<String, dynamic> json) {
    final donation = json['donation'];
    final donationId = donation is Map
        ? (donation['_id'] ?? donation['id'] ?? '').toString()
        : '';
    return DonationCreateResult(
      donationId: donationId,
      razorpayOrderId: (json['razorpay_order_id'] ?? '').toString(),
      razorpayKeyId: (json['razorpay_key_id'] ?? '').toString(),
      amount: json['amount'] ?? 0,
      currency: (json['currency'] ?? 'INR').toString(),
    );
  }
}
