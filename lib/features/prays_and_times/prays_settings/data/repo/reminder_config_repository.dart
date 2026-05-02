import 'dart:convert';

import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import '../model/prayer_reminder_config.dart';
import '../model/reminder_instance.dart';

/// Persists and retrieves [PrayerReminderConfig] and [ReminderInstance] data.
///
/// All storage is flat [SharedPreferences] keys, grouped by a schema version
/// marker so future migrations can detect and convert old data safely.
///
/// Schema version 1 key layout:
///   reminder_schema_version          → int (1)
///   reminder_config_{i}              → JSON string of PrayerReminderConfig
///   reminder_once_instances_v1       → JSON string of List<ReminderInstance>
class ReminderConfigRepository {
  static const int _schemaVersion = 1;
  static const String _schemaVersionKey = 'reminder_schema_version';
  static const String _oncInstancesKey = 'reminder_once_instances_v1';
  static const int _prayerCount = 7;

  static String _configKey(int prayerIndex) => 'reminder_config_$prayerIndex';

  // ---------------------------------------------------------------------------
  // Schema migration
  // ---------------------------------------------------------------------------

  /// Must be called once on app start (before any other method).
  /// Creates default configs for existing users and writes schema version.
  static void runMigrationIfNeeded() {
    final int stored =
        CacheHelper.getData(key: _schemaVersionKey) as int? ?? 0;
    if (stored >= _schemaVersion) return;

    print('[ReminderConfigRepository] Migrating to schema v$_schemaVersion');

    // Write default configs for all prayers without overwriting existing data.
    for (int i = 0; i < _prayerCount; i++) {
      final existing = CacheHelper.getData(key: _configKey(i));
      if (existing == null) {
        CacheHelper.saveData(
          key: _configKey(i),
          value: PrayerReminderConfig.defaultConfig.toJsonString(),
        );
      }
    }

    // Ensure once-instances list exists.
    if (CacheHelper.getData(key: _oncInstancesKey) == null) {
      CacheHelper.saveData(key: _oncInstancesKey, value: '[]');
    }

    CacheHelper.saveData(key: _schemaVersionKey, value: _schemaVersion);
    print('[ReminderConfigRepository] Migration complete.');
  }

  // ---------------------------------------------------------------------------
  // Configs
  // ---------------------------------------------------------------------------

  /// Loads all 7 prayer reminder configs.
  /// Missing or corrupted entries fall back to [PrayerReminderConfig.defaultConfig].
  static List<PrayerReminderConfig> loadAllConfigs() {
    return List.generate(_prayerCount, (i) => loadConfig(i));
  }

  static PrayerReminderConfig loadConfig(int prayerIndex) {
    try {
      final String? raw =
          CacheHelper.getData(key: _configKey(prayerIndex)) as String?;
      if (raw == null || raw.isEmpty) return PrayerReminderConfig.defaultConfig;
      return PrayerReminderConfig.fromJsonString(raw);
    } catch (e) {
      print(
          '[ReminderConfigRepository] Corrupt config for prayer $prayerIndex, using defaults. Error: $e');
      return PrayerReminderConfig.defaultConfig;
    }
  }

  static void saveConfig(int prayerIndex, PrayerReminderConfig config) {
    CacheHelper.saveData(
      key: _configKey(prayerIndex),
      value: config.toJsonString(),
    );
  }

  // ---------------------------------------------------------------------------
  // Once instances
  // ---------------------------------------------------------------------------

  static List<ReminderInstance> loadAllOnceInstances() {
    try {
      final String? raw =
          CacheHelper.getData(key: _oncInstancesKey) as String?;
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) =>
              ReminderInstance.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      print('[ReminderConfigRepository] Error loading once instances: $e');
      return [];
    }
  }

  static void saveOnceInstances(List<ReminderInstance> instances) {
    final encoded = jsonEncode(instances.map((e) => e.toJson()).toList());
    CacheHelper.saveData(key: _oncInstancesKey, value: encoded);
  }

  /// Upserts a [ReminderInstance] into the once-instances list.
  static void upsertOnceInstance(ReminderInstance instance) {
    final instances = loadAllOnceInstances();
    final idx = instances.indexWhere((e) => e.id == instance.id);
    if (idx >= 0) {
      instances[idx] = instance;
    } else {
      instances.add(instance);
    }
    saveOnceInstances(instances);
  }

  /// Marks a once-instance as consumed by its [instanceId].
  static void markConsumed(String instanceId, ConsumeReason reason) {
    final instances = loadAllOnceInstances();
    final idx = instances.indexWhere((e) => e.id == instanceId);
    if (idx >= 0) {
      instances[idx] = instances[idx].copyWithConsumed(reason);
      saveOnceInstances(instances);
      print(
          '[ReminderConfigRepository] Marked instance $instanceId as consumed (${reason.name})');
    }
  }

  /// Returns true if the given once-instance id was already consumed.
  static bool isConsumed(String instanceId) {
    final instances = loadAllOnceInstances();
    final match = instances.where((e) => e.id == instanceId);
    if (match.isEmpty) return false;
    return match.first.consumed;
  }

  /// Removes all consumed instances older than [maxAge] to prevent unbounded growth.
  static void pruneConsumedInstances({Duration maxAge = const Duration(days: 7)}) {
    final now = DateTime.now();
    final instances = loadAllOnceInstances()
        .where((e) =>
            !e.consumed ||
            (e.consumedAt != null &&
                now.difference(e.consumedAt!) < maxAge))
        .toList();
    saveOnceInstances(instances);
  }
}
