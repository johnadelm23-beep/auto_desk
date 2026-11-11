class NotificationSettingsModel {
  final bool notificationsEnabled;
  final bool advanceReminderEnabled;
  final int advanceReminderMinutes; // 15 or 30

  const NotificationSettingsModel({
    this.notificationsEnabled = true,
    this.advanceReminderEnabled = true,
    this.advanceReminderMinutes = 30,
  });

  NotificationSettingsModel copyWith({
    bool? notificationsEnabled,
    bool? advanceReminderEnabled,
    int? advanceReminderMinutes,
  }) {
    return NotificationSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      advanceReminderEnabled:
          advanceReminderEnabled ?? this.advanceReminderEnabled,
      advanceReminderMinutes:
          advanceReminderMinutes ?? this.advanceReminderMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'advanceReminderEnabled': advanceReminderEnabled,
      'advanceReminderMinutes': advanceReminderMinutes,
    };
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      advanceReminderEnabled: map['advanceReminderEnabled'] as bool? ?? true,
      advanceReminderMinutes: map['advanceReminderMinutes'] as int? ?? 30,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettingsModel &&
        other.notificationsEnabled == notificationsEnabled &&
        other.advanceReminderEnabled == advanceReminderEnabled &&
        other.advanceReminderMinutes == advanceReminderMinutes;
  }

  @override
  int get hashCode {
    return notificationsEnabled.hashCode ^
        advanceReminderEnabled.hashCode ^
        advanceReminderMinutes.hashCode;
  }
}

