import 'package:flutter/material.dart';

class QueueItem {
  final int queueId;
  final String messageId;
  final String subject;
  final String? senderName;
  final String senderEmail;
  final String? suggestedStatus;
  final String confidence;
  final String? extractedName;
  final String? extractedEmail;
  final String? suggestedRecruitmentTitle;
  final String? attachmentsJson;
  final String hrStatus;
  final String? hrNotes;
  final String createdAt;

  QueueItem({
    required this.queueId,
    required this.messageId,
    required this.subject,
    this.senderName,
    required this.senderEmail,
    this.suggestedStatus,
    required this.confidence,
    this.extractedName,
    this.extractedEmail,
    this.suggestedRecruitmentTitle,
    this.attachmentsJson,
    required this.hrStatus,
    this.hrNotes,
    required this.createdAt,
  });

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      queueId: json['queue_id'] ?? 0,
      messageId: json['message_id'] ?? '',
      subject: json['subject'] ?? '',
      senderName: json['sender_name'],
      senderEmail: json['sender_email'] ?? '',
      suggestedStatus: json['suggested_status'],
      confidence: json['confidence'] ?? 'low',
      extractedName: json['extracted_name'],
      extractedEmail: json['extracted_email'],
      suggestedRecruitmentTitle: json['suggested_recruitment_title'],
      attachmentsJson: json['attachments_json'],
      hrStatus: json['hr_status'] ?? 'pending',
      hrNotes: json['hr_notes'],
      createdAt: json['created_at'] ?? '',
    );
  }

  static const Map<String, Color> confidenceColors = {
    'high': Color(0xFF10b981),
    'medium': Color(0xFFf59e0b),
    'low': Color(0xFF9ca3af),
  };

  static const Map<String, String> statusLabels = {
    'pending': '待处理',
    'confirmed': '已确认',
    'adjusted': '已调整',
    'ignored': '已忽略',
  };
}
