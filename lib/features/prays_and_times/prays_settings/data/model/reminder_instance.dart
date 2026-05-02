import 'prayer_reminder_config.dart';

/// Reason a once-reminder was consumed without firing.
enum ConsumeReason { fired, expiredStale, modeChanged, slotDisabled, prayerDisabled }

/// Represents a concrete scheduled reminder for one occurrence of a prayer.
///
/// Both [ReminderMode.frequent] and [ReminderMode.once] share this model.
/// For frequent reminders, [consumed] stays false — the next reconciliation
/// simply replaces the work entry. For once reminders, the [consumed] flag
/// is persisted so it is never re-scheduled after it fires or expires.
class ReminderInstance {
  /// Stable identity:
  ///   frequent → `r_freq_{prayerIndex}_{typeName}`
  ///   once     → `r_once_{prayerIndex}_{typeName}_{adhanEpochMillis}`
  final String id;

  final int prayerIndex;
  final ReminderType type;
  final ReminderMode mode;

  /// Epoch millis of the adhan this reminder is anchored to.
  final int adhanEpochMillis;

  /// Epoch millis at which this reminder should fire.
  /// Invariant: before → trigger < adhan ; after → trigger > adhan.
  final int triggerEpochMillis;

  final int offsetMinutes;
  final bool consumed;
  final DateTime createdAt;
  final DateTime? consumedAt;
  final ConsumeReason? consumeReason;

  const ReminderInstance({
    required this.id,
    required this.prayerIndex,
    required this.type,
    required this.mode,
    required this.adhanEpochMillis,
    required this.triggerEpochMillis,
    required this.offsetMinutes,
    required this.consumed,
    required this.createdAt,
    this.consumedAt,
    this.consumeReason,
  });

  ReminderInstance copyWithConsumed(ConsumeReason reason) => ReminderInstance(
        id: id,
        prayerIndex: prayerIndex,
        type: type,
        mode: mode,
        adhanEpochMillis: adhanEpochMillis,
        triggerEpochMillis: triggerEpochMillis,
        offsetMinutes: offsetMinutes,
        consumed: true,
        createdAt: createdAt,
        consumedAt: DateTime.now(),
        consumeReason: reason,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'prayerIndex': prayerIndex,
        'type': type.name,
        'mode': mode.name,
        'adhanEpochMillis': adhanEpochMillis,
        'triggerEpochMillis': triggerEpochMillis,
        'offsetMinutes': offsetMinutes,
        'consumed': consumed,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'consumedAt': consumedAt?.millisecondsSinceEpoch,
        'consumeReason': consumeReason?.name,
      };

  factory ReminderInstance.fromJson(Map<String, dynamic> json) =>
      ReminderInstance(
        id: json['id'] as String,
        prayerIndex: json['prayerIndex'] as int,
        type: ReminderType.values.firstWhere((e) => e.name == json['type']),
        mode: ReminderMode.values.firstWhere((e) => e.name == json['mode']),
        adhanEpochMillis: json['adhanEpochMillis'] as int,
        triggerEpochMillis: json['triggerEpochMillis'] as int,
        offsetMinutes: json['offsetMinutes'] as int,
        consumed: json['consumed'] as bool? ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] as int),
        consumedAt: json['consumedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json['consumedAt'] as int)
            : null,
        consumeReason: json['consumeReason'] != null
            ? ConsumeReason.values.firstWhere(
                (e) => e.name == json['consumeReason'],
                orElse: () => ConsumeReason.fired)
            : null,
      );

  /// Builds a deterministic WorkManager unique-work name for this instance.
  String get workManagerName {
    if (mode == ReminderMode.frequent) {
      return 'reminder_freq_${prayerIndex}_${type.name}';
    }
    return 'reminder_once_${prayerIndex}_${type.name}_$adhanEpochMillis';
  }

  /// Builds the instance [id] for a frequent slot (no epoch in ID — stable).
  static String frequentId(int prayerIndex, ReminderType type) =>
      'r_freq_${prayerIndex}_${type.name}';

  /// Builds the instance [id] for a once slot.
  static String onceId(
          int prayerIndex, ReminderType type, int adhanEpochMillis) =>
      'r_once_${prayerIndex}_${type.name}_$adhanEpochMillis';
}
