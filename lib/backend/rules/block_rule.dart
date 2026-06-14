/// Represents a rule for blocking a specific website.
class BlockRule {
  final String id;
  final String categoryId;
  final String domain; // also represents app name if isAppRule is true
  final Duration blockDuration;
  final bool isActive;
  final DateTime? lastActivatedAt;

  // Premium Features
  final bool isStrictMode;
  final bool isAppRule;
  final List<int>? scheduledDays; // e.g. [1, 2, 3] for Mon, Tue, Wed
  final String? startTime; // e.g. "09:00"
  final String? endTime; // e.g. "17:00"
  
  // Sync Status
  final String syncStatus; // 'staged', 'synced', 'failed'

  const BlockRule({
    required this.id,
    required this.categoryId,
    required this.domain,
    required this.blockDuration,
    this.isActive = true,
    this.lastActivatedAt,
    this.isStrictMode = false,
    this.isAppRule = false,
    this.scheduledDays,
    this.startTime,
    this.endTime,
    this.syncStatus = 'synced',
  });

  BlockRule copyWith({
    String? id,
    String? categoryId,
    String? domain,
    Duration? blockDuration,
    bool? isActive,
    DateTime? lastActivatedAt,
    bool? isStrictMode,
    bool? isAppRule,
    List<int>? scheduledDays,
    String? startTime,
    String? endTime,
    String? syncStatus,
  }) {
    return BlockRule(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      domain: domain ?? this.domain,
      blockDuration: blockDuration ?? this.blockDuration,
      isActive: isActive ?? this.isActive,
      lastActivatedAt: lastActivatedAt ?? this.lastActivatedAt,
      isStrictMode: isStrictMode ?? this.isStrictMode,
      isAppRule: isAppRule ?? this.isAppRule,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'domain': domain,
      'blockDurationSeconds': blockDuration.inSeconds,
      'isActive': isActive,
      'lastActivatedAt': lastActivatedAt?.millisecondsSinceEpoch,
      'isStrictMode': isStrictMode,
      'isAppRule': isAppRule,
      'scheduledDays': scheduledDays,
      'startTime': startTime,
      'endTime': endTime,
      'syncStatus': syncStatus,
    };
  }

  factory BlockRule.fromJson(Map<String, dynamic> json) {
    return BlockRule(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      domain: json['domain'] as String,
      blockDuration: Duration(seconds: (json['blockDurationSeconds'] as int?) ?? 0),
      isActive: (json['isActive'] as bool?) ?? true,
      lastActivatedAt: json['lastActivatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastActivatedAt'] as int)
          : null,
      isStrictMode: (json['isStrictMode'] as bool?) ?? false,
      isAppRule: (json['isAppRule'] as bool?) ?? false,
      scheduledDays: json['scheduledDays'] != null ? List<int>.from(json['scheduledDays'] as Iterable) : null,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      syncStatus: (json['syncStatus'] as String?) ?? 'synced',
    );
  }
}
