/// Block Model
class Block {
  final String id;
  final String uid;
  final String blockedId;
  final String? blockedUserName;
  final String? reason;
  final String createdAt;

  Block({
    required this.id,
    required this.uid,
    required this.blockedId,
    this.blockedUserName,
    this.reason,
    required this.createdAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'],
      uid: json['uid'],
      blockedId: json['blocked_id'] ?? json['blocked_user_id'],
      blockedUserName: json['blocked_user_name'],
      reason: json['reason'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'blocked_id': blockedId,
      if (blockedUserName != null) 'blocked_user_name': blockedUserName,
      if (reason != null) 'reason': reason,
      'created_at': createdAt,
    };
  }
}

/// Report Model
class Report {
  final String id;
  final String uid;
  final String reportedId;
  final String reason;
  final String? details;
  final String status;
  final String createdAt;
  final String? referenceId;

  Report({
    required this.id,
    required this.uid,
    required this.reportedId,
    required this.reason,
    this.details,
    required this.status,
    required this.createdAt,
    this.referenceId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      uid: json['uid'],
      reportedId: json['reported_id'],
      reason: json['reason'],
      details: json['details'],
      status: json['status'],
      createdAt: json['created_at'],
      referenceId: json['reference_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'reported_id': reportedId,
      'reason': reason,
      if (details != null) 'details': details,
      'status': status,
      'created_at': createdAt,
      if (referenceId != null) 'reference_id': referenceId,
    };
  }

  bool get isSubmitted => status == 'submitted';
  bool get isUnderReview => status == 'under_review';
  bool get isResolved => status == 'resolved';
}

/// Common report reasons
class ReportReason {
  static const String spam = 'spam';
  static const String harassment = 'harassment';
  static const String inappropriateContent = 'inappropriate_content';
  static const String fakeProfile = 'fake_profile';
  static const String underage = 'underage';
  static const String other = 'other';

  static List<String> get allReasons => [
        spam,
        harassment,
        inappropriateContent,
        fakeProfile,
        underage,
        other,
      ];

  static String getDisplayName(String reason) {
    switch (reason) {
      case spam:
        return 'Spam';
      case harassment:
        return 'Harassment';
      case inappropriateContent:
        return 'Inappropriate Content';
      case fakeProfile:
        return 'Fake Profile';
      case underage:
        return 'Underage User';
      case other:
        return 'Other';
      default:
        return reason;
    }
  }
}
