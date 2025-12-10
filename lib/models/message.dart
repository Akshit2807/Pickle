/// Message Model
class Message {
  final String id;
  final String fromUid;
  final String fromName;
  final String content;
  final String createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      fromUid: json['from_uid'],
      fromName: json['from_name'],
      content: json['content'],
      createdAt: json['created_at'],
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_uid': fromUid,
      'from_name': fromName,
      'content': content,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }

  // Check if message is from current user
  bool isFromUser(String currentUid) => fromUid == currentUid;

  Message copyWith({
    String? id,
    String? fromUid,
    String? fromName,
    String? content,
    String? createdAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      fromUid: fromUid ?? this.fromUid,
      fromName: fromName ?? this.fromName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
