class ApplicationMaterials {
  final Map<String, dynamic>? candidate;
  final QueueItemMaterials? queueItem;
  final ResumeParseResult? resumeParse;
  final Map<String, dynamic>? classifierInfo;
  final List<CorrectionEntry>? corrections;

  ApplicationMaterials({
    this.candidate,
    this.queueItem,
    this.resumeParse,
    this.classifierInfo,
    this.corrections,
  });

  factory ApplicationMaterials.fromJson(Map<String, dynamic> json) {
    return ApplicationMaterials(
      candidate: json['candidate'] as Map<String, dynamic>?,
      queueItem: json['queue_item'] != null
          ? QueueItemMaterials.fromJson(json['queue_item'] as Map<String, dynamic>)
          : null,
      resumeParse: json['resume_parse'] != null
          ? ResumeParseResult.fromJson(json['resume_parse'] as Map<String, dynamic>)
          : null,
      classifierInfo: json['classifier_info'] as Map<String, dynamic>?,
      corrections: json['corrections'] != null
          ? (json['corrections'] as List)
              .map((e) => CorrectionEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class QueueItemMaterials {
  final String subject;
  final String? senderName;
  final String senderEmail;
  final String? body;
  final String? bodyText;
  final List<AttachmentInfo>? attachments;

  QueueItemMaterials({
    required this.subject,
    this.senderName,
    required this.senderEmail,
    this.body,
    this.bodyText,
    this.attachments,
  });

  factory QueueItemMaterials.fromJson(Map<String, dynamic> json) {
    return QueueItemMaterials(
      subject: json['subject'] ?? '',
      senderName: json['sender_name'] as String?,
      senderEmail: json['sender_email'] ?? '',
      body: json['body'] as String?,
      bodyText: json['body_text'] as String?,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => AttachmentInfo.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class AttachmentInfo {
  final String id;
  final String filename;
  final String? mimeType;
  final int size;
  final String? storagePath;

  AttachmentInfo({
    required this.id,
    required this.filename,
    this.mimeType,
    this.size = 0,
    this.storagePath,
  });

  factory AttachmentInfo.fromJson(Map<String, dynamic> json) {
    return AttachmentInfo(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      mimeType: json['mime_type'] as String?,
      size: json['size'] ?? 0,
      storagePath: json['storage_path'] as String?,
    );
  }
}

class ResumeParseResult {
  final String status;
  final String? textExcerpt;
  final String? name;
  final String? phone;
  final String? email;
  final String? error;

  ResumeParseResult({
    required this.status,
    this.textExcerpt,
    this.name,
    this.phone,
    this.email,
    this.error,
  });

  factory ResumeParseResult.fromJson(Map<String, dynamic> json) {
    return ResumeParseResult(
      status: json['status'] ?? '',
      textExcerpt: json['text_excerpt'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      error: json['error'] as String?,
    );
  }
}

class CorrectionEntry {
  final String fieldName;
  final String? originalValue;
  final String? correctedValue;
  final String createdAt;

  CorrectionEntry({
    required this.fieldName,
    this.originalValue,
    this.correctedValue,
    required this.createdAt,
  });

  factory CorrectionEntry.fromJson(Map<String, dynamic> json) {
    return CorrectionEntry(
      fieldName: json['field_name'] ?? '',
      originalValue: json['original_value'] as String?,
      correctedValue: json['corrected_value'] as String?,
      createdAt: json['created_at'] ?? '',
    );
  }
}
