/// Swipe Action Model
class SwipeAction {
  final String? id;
  final String uid;
  final String swipedId;
  final String action; // "like" or "pass"
  final bool? isMatch;
  final String? matchId;
  final String? createdAt;
  final String? matchedAt;
  final String? message;

  SwipeAction({
    this.id,
    required this.uid,
    required this.swipedId,
    required this.action,
    this.isMatch,
    this.matchId,
    this.createdAt,
    this.matchedAt,
    this.message,
  });

  factory SwipeAction.fromJson(Map<String, dynamic> json) {
    return SwipeAction(
      id: json['id'],
      uid: json['uid'],
      swipedId: json['swiped_id'],
      action: json['action'],
      isMatch: json['is_match'],
      matchId: json['match_id'],
      createdAt: json['created_at'],
      matchedAt: json['matched_at'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'swiped_id': swipedId,
      'action': action,
      if (isMatch != null) 'is_match': isMatch,
      if (matchId != null) 'match_id': matchId,
      if (createdAt != null) 'created_at': createdAt,
      if (matchedAt != null) 'matched_at': matchedAt,
      if (message != null) 'message': message,
    };
  }

  bool get isLike => action == 'like';
  bool get isPass => action == 'pass';
}

/// Swipe History Item
class SwipeHistoryItem {
  final String id;
  final String swipedId;
  final String swipedName;
  final String action;
  final String createdAt;

  SwipeHistoryItem({
    required this.id,
    required this.swipedId,
    required this.swipedName,
    required this.action,
    required this.createdAt,
  });

  factory SwipeHistoryItem.fromJson(Map<String, dynamic> json) {
    return SwipeHistoryItem(
      id: json['id'],
      swipedId: json['swiped_id'],
      swipedName: json['swiped_name'],
      action: json['action'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'swiped_id': swipedId,
      'swiped_name': swipedName,
      'action': action,
      'created_at': createdAt,
    };
  }
}
