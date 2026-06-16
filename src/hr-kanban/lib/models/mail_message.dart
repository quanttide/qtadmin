class MailMessage {
  final int id;
  final int? candidateId;
  final int? applicationId;
  final String? messageId;
  final String? senderEmail;
  final String? recipientEmail;
  final String subject;
  final String? body;
  final String? bodyText;
  final String? attachmentsJson;
  final String? stageSnapshot;
  final String direction;
  final String sendStatus;
  final String occurredAt;

  MailMessage({
    required this.id,
    this.candidateId,
    this.applicationId,
    this.messageId,
    this.senderEmail,
    this.recipientEmail,
    required this.subject,
    this.body,
    this.bodyText,
    this.attachmentsJson,
    this.stageSnapshot,
    required this.direction,
    this.sendStatus = '',
    required this.occurredAt,
  });

  factory MailMessage.fromJson(Map<String, dynamic> json) {
    return MailMessage(
      id: json['id'] ?? 0,
      candidateId: json['candidate_id'],
      applicationId: json['application_id'],
      messageId: json['message_id'],
      senderEmail: json['sender_email'],
      recipientEmail: json['recipient_email'],
      subject: json['subject'] ?? '',
      body: json['body'],
      bodyText: json['body_text'],
      attachmentsJson: json['attachments_json'],
      stageSnapshot: json['stage_snapshot'],
      direction: json['direction'] ?? 'inbound',
      sendStatus: json['send_status'] ?? '',
      occurredAt: json['occurred_at'] ?? '',
    );
  }
}

class TimelineItem {
  final String type;
  final String timestamp;
  final String description;
  final Map<String, dynamic>? detail;

  TimelineItem({
    required this.type,
    required this.timestamp,
    required this.description,
    this.detail,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      type: json['type'] ?? '',
      timestamp: json['timestamp'] ?? '',
      description: json['description'] ?? '',
      detail: json['detail'] as Map<String, dynamic>?,
    );
  }
}
