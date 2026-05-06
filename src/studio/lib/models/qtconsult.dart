import 'package:flutter/material.dart';

enum DiscoveryType { risk, concern, opportunity, neutral }

enum DiscoveryStatus { pending, confirmed, dismissed }

enum StakeStance { support, neutral, oppose }

class DiscoveryData {
  final String id;
  final String text;
  final DiscoveryType type;
  final DiscoveryStatus status;
  final String source;
  final String date;
  final bool linkedToStrategy;

  const DiscoveryData({
    required this.id,
    required this.text,
    required this.type,
    this.status = DiscoveryStatus.pending,
    required this.source,
    required this.date,
    this.linkedToStrategy = false,
  });

  factory DiscoveryData.fromJson(Map<String, dynamic> json) {
    return DiscoveryData(
      id: json['id'] as String,
      text: json['text'] as String,
      type: DiscoveryType.values.byName(json['type'] as String),
      status: DiscoveryStatus.values.byName(json['status'] as String),
      source: json['source'] as String,
      date: json['date'] as String,
      linkedToStrategy: json['linkedToStrategy'] as bool? ?? false,
    );
  }

  DiscoveryData copyWith({
    DiscoveryStatus? status,
    String? date,
    bool? linkedToStrategy,
  }) {
    return DiscoveryData(
      id: id,
      text: text,
      type: type,
      status: status ?? this.status,
      source: source,
      date: date ?? this.date,
      linkedToStrategy: linkedToStrategy ?? this.linkedToStrategy,
    );
  }
}

class CommunicationData {
  final String id;
  final String title;
  final String date;
  final String summary;

  const CommunicationData({
    required this.id,
    required this.title,
    required this.date,
    required this.summary,
  });

  factory CommunicationData.fromJson(Map<String, dynamic> json) {
    return CommunicationData(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      summary: json['summary'] as String,
    );
  }
}

class StakeholderData {
  final String id;
  final String name;
  final String role;
  final StakeStance stance;
  final String concern;
  final String detail;

  const StakeholderData({
    required this.id,
    required this.name,
    required this.role,
    required this.stance,
    required this.concern,
    required this.detail,
  });

  factory StakeholderData.fromJson(Map<String, dynamic> json) {
    return StakeholderData(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      stance: StakeStance.values.byName(json['stance'] as String),
      concern: json['concern'] as String,
      detail: json['detail'] as String,
    );
  }

  String get stanceLabel {
    switch (stance) {
      case StakeStance.support:
        return '支持';
      case StakeStance.neutral:
        return '中立';
      case StakeStance.oppose:
        return '反对';
    }
  }
}

class StrategyRevisionData {
  final String id;
  final String date;
  final String reason;
  final String? relatedDiscoveryId;
  final bool isReviewed;

  const StrategyRevisionData({
    required this.id,
    required this.date,
    required this.reason,
    this.relatedDiscoveryId,
    this.isReviewed = false,
  });

  factory StrategyRevisionData.fromJson(Map<String, dynamic> json) {
    return StrategyRevisionData(
      id: json['id'] as String,
      date: json['date'] as String,
      reason: json['reason'] as String,
      relatedDiscoveryId: json['relatedDiscoveryId'] as String?,
      isReviewed: json['isReviewed'] as bool? ?? false,
    );
  }

  StrategyRevisionData copyWith({bool? isReviewed, String? date}) {
    return StrategyRevisionData(
      id: id,
      date: date ?? this.date,
      reason: reason,
      relatedDiscoveryId: relatedDiscoveryId,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}

class QtConsultData {
  final String projectName;
  final String phase;
  final String industry;
  final String scale;
  final String maturity;
  final String strategyGoal;
  final String strategyInsight;
  final List<String> strategySteps;
  final String riskNote;
  final List<DiscoveryData> discoveries;
  final List<CommunicationData> communications;
  final List<StrategyRevisionData> revisions;
  final List<StakeholderData> stakeholders;

  const QtConsultData({
    required this.projectName,
    required this.phase,
    required this.industry,
    required this.scale,
    required this.maturity,
    required this.strategyGoal,
    required this.strategyInsight,
    required this.strategySteps,
    required this.riskNote,
    required this.discoveries,
    required this.communications,
    required this.revisions,
    required this.stakeholders,
  });

  factory QtConsultData.fromJson(Map<String, dynamic> json) {
    return QtConsultData(
      projectName: json['projectName'] as String,
      phase: json['phase'] as String,
      industry: json['industry'] as String,
      scale: json['scale'] as String,
      maturity: json['maturity'] as String,
      strategyGoal: json['strategyGoal'] as String,
      strategyInsight: json['strategyInsight'] as String,
      strategySteps: (json['strategySteps'] as List<dynamic>).cast<String>(),
      riskNote: json['riskNote'] as String,
      discoveries: (json['discoveries'] as List<dynamic>)
          .map((d) => DiscoveryData.fromJson(d as Map<String, dynamic>))
          .toList(),
      communications: (json['communications'] as List<dynamic>)
          .map((c) => CommunicationData.fromJson(c as Map<String, dynamic>))
          .toList(),
      revisions: (json['revisions'] as List<dynamic>)
          .map((r) => StrategyRevisionData.fromJson(r as Map<String, dynamic>))
          .toList(),
      stakeholders: (json['stakeholders'] as List<dynamic>)
          .map((s) => StakeholderData.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

Color discoveryDotColor(DiscoveryType type) {
  switch (type) {
    case DiscoveryType.risk:
      return const Color(0xFFB71C1C);
    case DiscoveryType.concern:
      return const Color(0xFFC8690A);
    case DiscoveryType.opportunity:
      return const Color(0xFF1A7F37);
    case DiscoveryType.neutral:
      return const Color(0xFF1A5FDC);
  }
}

Color stanceColor(StakeStance stance) {
  switch (stance) {
    case StakeStance.support:
      return const Color(0xFF1A7F37);
    case StakeStance.neutral:
      return const Color(0xFF777777);
    case StakeStance.oppose:
      return const Color(0xFFB71C1C);
  }
}

Color stanceBgColor(StakeStance stance) {
  switch (stance) {
    case StakeStance.support:
      return const Color(0xFFE8F5E9);
    case StakeStance.neutral:
      return const Color(0xFFF5F5F5);
    case StakeStance.oppose:
      return const Color(0xFFFFEBEE);
  }
}
