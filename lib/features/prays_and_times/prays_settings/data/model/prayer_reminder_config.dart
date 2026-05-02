import 'dart:convert';

/// Direction of a reminder relative to the adhan.
enum ReminderType { before, after }

/// Whether a reminder fires every occurrence or only once.
enum ReminderMode { frequent, once }

/// Configuration for a single reminder slot (before OR after adhan).
class ReminderSlotConfig {
  final bool enabled;
  final ReminderMode mode;

  /// Must be > 0. Interpreted as minutes before/after adhan depending on slot.
  final int offsetMinutes;

  const ReminderSlotConfig({
    required this.enabled,
    required this.mode,
    required this.offsetMinutes,
  });

  ReminderSlotConfig copyWith({
    bool? enabled,
    ReminderMode? mode,
    int? offsetMinutes,
  }) {
    return ReminderSlotConfig(
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'mode': mode.name,
        'offsetMinutes': offsetMinutes,
      };

  factory ReminderSlotConfig.fromJson(Map<String, dynamic> json) =>
      ReminderSlotConfig(
        enabled: json['enabled'] as bool? ?? false,
        mode: ReminderMode.values.firstWhere(
          (e) => e.name == json['mode'],
          orElse: () => ReminderMode.frequent,
        ),
        offsetMinutes: json['offsetMinutes'] as int? ?? 10,
      );

  /// Safe defaults: disabled, frequent mode, 10-minute offset.
  static const ReminderSlotConfig defaultDisabled = ReminderSlotConfig(
    enabled: false,
    mode: ReminderMode.frequent,
    offsetMinutes: 10,
  );
}

/// Combined before + after configuration for a single prayer.
class PrayerReminderConfig {
  final ReminderSlotConfig before;
  final ReminderSlotConfig after;

  const PrayerReminderConfig({
    required this.before,
    required this.after,
  });

  PrayerReminderConfig copyWith({
    ReminderSlotConfig? before,
    ReminderSlotConfig? after,
  }) {
    return PrayerReminderConfig(
      before: before ?? this.before,
      after: after ?? this.after,
    );
  }

  Map<String, dynamic> toJson() => {
        'before': before.toJson(),
        'after': after.toJson(),
      };

  factory PrayerReminderConfig.fromJson(Map<String, dynamic> json) =>
      PrayerReminderConfig(
        before: ReminderSlotConfig.fromJson(
            (json['before'] as Map?)?.cast<String, dynamic>() ?? {}),
        after: ReminderSlotConfig.fromJson(
            (json['after'] as Map?)?.cast<String, dynamic>() ?? {}),
      );

  /// Both slots disabled — used as safe default for all prayers on first install.
  static const PrayerReminderConfig defaultConfig = PrayerReminderConfig(
    before: ReminderSlotConfig.defaultDisabled,
    after: ReminderSlotConfig.defaultDisabled,
  );

  String toJsonString() => jsonEncode(toJson());

  factory PrayerReminderConfig.fromJsonString(String s) =>
      PrayerReminderConfig.fromJson(
          jsonDecode(s) as Map<String, dynamic>);
}
