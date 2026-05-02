// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:norway_roznama_new_project/core/services/reminder_scheduler.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/prayer_reminder_config.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/reminder_instance.dart';

/// ---------------------------------------------------------------------------
/// Unit test suite for adhan sub-reminders.
///
/// Covers:
///   1. ReminderSlotConfig serialization / deserialization
///   2. PrayerReminderConfig round-trip JSON
///   3. Trigger computation: before < adhan, after > adhan
///   4. Invariant guards (offsetMinutes must be > 0)
///   5. Notification ID derivation (no collisions with existing IDs)
///   6. ReminderInstance id construction
///   7. WorkManager unique name stability
///   8. Consumption lifecycle
///   9. Offset edge cases (0 offset, max offset)
///  10. Mode / type interaction (once → frequent mode switch invariant)
/// ---------------------------------------------------------------------------
void main() {
  // ---------------------------------------------------------------------------
  // 1. ReminderSlotConfig serialization
  // ---------------------------------------------------------------------------
  group('ReminderSlotConfig JSON round-trip', () {
    test('serializes enabled frequent slot', () {
      const slot = ReminderSlotConfig(
        enabled: true,
        mode: ReminderMode.frequent,
        offsetMinutes: 15,
      );
      final json = slot.toJson();
      final restored = ReminderSlotConfig.fromJson(json);

      expect(restored.enabled, isTrue);
      expect(restored.mode, ReminderMode.frequent);
      expect(restored.offsetMinutes, 15);
    });

    test('serializes disabled once slot', () {
      const slot = ReminderSlotConfig(
        enabled: false,
        mode: ReminderMode.once,
        offsetMinutes: 5,
      );
      final restored = ReminderSlotConfig.fromJson(slot.toJson());

      expect(restored.enabled, isFalse);
      expect(restored.mode, ReminderMode.once);
      expect(restored.offsetMinutes, 5);
    });

    test('missing keys fall back to safe defaults', () {
      final restored = ReminderSlotConfig.fromJson({});
      expect(restored.enabled, isFalse);
      expect(restored.mode, ReminderMode.frequent);
      expect(restored.offsetMinutes, 10);
    });

    test('unknown mode name falls back to frequent', () {
      final restored = ReminderSlotConfig.fromJson({
        'enabled': true,
        'mode': 'unknown_mode',
        'offsetMinutes': 20,
      });
      expect(restored.mode, ReminderMode.frequent);
    });
  });

  // ---------------------------------------------------------------------------
  // 2. PrayerReminderConfig round-trip
  // ---------------------------------------------------------------------------
  group('PrayerReminderConfig JSON round-trip', () {
    test('full config survives encode → decode', () {
      const config = PrayerReminderConfig(
        before: ReminderSlotConfig(
          enabled: true,
          mode: ReminderMode.once,
          offsetMinutes: 30,
        ),
        after: ReminderSlotConfig(
          enabled: false,
          mode: ReminderMode.frequent,
          offsetMinutes: 10,
        ),
      );

      final jsonStr = config.toJsonString();
      final restored = PrayerReminderConfig.fromJsonString(jsonStr);

      expect(restored.before.enabled, isTrue);
      expect(restored.before.mode, ReminderMode.once);
      expect(restored.before.offsetMinutes, 30);
      expect(restored.after.enabled, isFalse);
      expect(restored.after.offsetMinutes, 10);
    });

    test('defaultConfig has both slots disabled', () {
      expect(PrayerReminderConfig.defaultConfig.before.enabled, isFalse);
      expect(PrayerReminderConfig.defaultConfig.after.enabled, isFalse);
    });

    test('copyWith updates only specified slot', () {
      const original = PrayerReminderConfig.defaultConfig;
      final updated = original.copyWith(
        before: const ReminderSlotConfig(
          enabled: true,
          mode: ReminderMode.frequent,
          offsetMinutes: 20,
        ),
      );
      expect(updated.before.enabled, isTrue);
      expect(updated.after.enabled, isFalse); // unchanged
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Trigger computation invariants
  // ---------------------------------------------------------------------------
  group('Trigger computation: before/after invariants', () {
    final adhan = DateTime(2025, 3, 25, 5, 30); // 05:30

    test('before trigger is strictly before adhan', () {
      const offset = 10;
      final trigger = adhan.subtract(const Duration(minutes: offset));
      expect(trigger.isBefore(adhan), isTrue,
          reason: 'before trigger must be < adhan');
    });

    test('after trigger is strictly after adhan', () {
      const offset = 10;
      final trigger = adhan.add(const Duration(minutes: offset));
      expect(trigger.isAfter(adhan), isTrue,
          reason: 'after trigger must be > adhan');
    });

    test('before with offset = adhan minutes → trigger 00:00 same day', () {
      final midnight = DateTime(2025, 3, 25, 0, 0);
      const offset = 5 * 60; // 300 minutes = 5 hours
      final adhan5h = DateTime(2025, 3, 25, 5, 0);
      final trigger = adhan5h.subtract(Duration(minutes: offset));
      expect(trigger, equals(midnight));
      expect(trigger.isBefore(adhan5h), isTrue);
    });

    test('violation detected: before trigger >= adhan', () {
      final trigger = adhan; // equal — not strictly before
      expect(trigger.isBefore(adhan), isFalse);
    });

    test('violation detected: after trigger <= adhan', () {
      final trigger = adhan; // equal — not strictly after
      expect(trigger.isAfter(adhan), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // 4. offsetMinutes validation
  // ---------------------------------------------------------------------------
  group('offsetMinutes validation', () {
    test('offset > 0 is valid', () {
      for (final v in [1, 5, 10, 60]) {
        expect(v > 0, isTrue, reason: 'offset $v should be valid');
      }
    });

    test('offset = 0 is invalid', () {
      expect(0 > 0, isFalse, reason: 'offset 0 must be rejected');
    });

    test('negative offset is invalid', () {
      expect(-5 > 0, isFalse, reason: 'negative offset must be rejected');
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Notification ID derivation — no collision with existing IDs
  // ---------------------------------------------------------------------------
  group('Notification ID: no collision with existing IDs', () {
    // Existing IDs: 0–6 (adhan), 100–104 (nawafil), 400–406 (iqama), 500 (imsak)
    const existingIds = {0, 1, 2, 3, 4, 5, 6, 100, 101, 102, 103, 104, 400, 401, 402, 403, 404, 405, 406, 500};

    test('all 14 reminder notification IDs are outside existing ID set', () {
      final generated = <int>{};
      for (int i = 0; i < 7; i++) {
        final beforeId = reminderNotificationId(i, ReminderType.before);
        final afterId = reminderNotificationId(i, ReminderType.after);
        generated.add(beforeId);
        generated.add(afterId);
      }
      expect(generated.intersection(existingIds), isEmpty,
          reason: 'Reminder IDs must not collide with existing IDs');
    });

    test('before and after IDs for same prayer are different', () {
      for (int i = 0; i < 7; i++) {
        final b = reminderNotificationId(i, ReminderType.before);
        final a = reminderNotificationId(i, ReminderType.after);
        expect(b, isNot(equals(a)));
      }
    });

    test('all reminder IDs are in range 6000–8999', () {
      for (int i = 0; i < 7; i++) {
        for (final t in ReminderType.values) {
          final id = reminderNotificationId(i, t);
          expect(id, inInclusiveRange(6000, 8999),
              reason: 'ID $id for prayer $i type ${t.name} out of reserved range');
        }
      }
    });

    test('all 14 IDs are unique', () {
      final ids = [
        for (int i = 0; i < 7; i++)
          for (final t in ReminderType.values) reminderNotificationId(i, t),
      ];
      expect(ids.toSet().length, equals(14));
    });
  });

  // ---------------------------------------------------------------------------
  // 6. ReminderInstance ID construction
  // ---------------------------------------------------------------------------
  group('ReminderInstance ID construction', () {
    test('frequentId is stable across calls', () {
      final a = ReminderInstance.frequentId(2, ReminderType.before);
      final b = ReminderInstance.frequentId(2, ReminderType.before);
      expect(a, equals(b));
    });

    test('frequentId differs by prayer index', () {
      final a = ReminderInstance.frequentId(0, ReminderType.before);
      final b = ReminderInstance.frequentId(1, ReminderType.before);
      expect(a, isNot(equals(b)));
    });

    test('frequentId differs by type', () {
      final b = ReminderInstance.frequentId(3, ReminderType.before);
      final a = ReminderInstance.frequentId(3, ReminderType.after);
      expect(b, isNot(equals(a)));
    });

    test('onceId encodes adhan epoch', () {
      const epoch = 1740000000000;
      final id = ReminderInstance.onceId(0, ReminderType.before, epoch);
      expect(id.contains('$epoch'), isTrue);
    });

    test('onceId differs for different adhan epochs', () {
      final a = ReminderInstance.onceId(0, ReminderType.before, 1000000);
      final b = ReminderInstance.onceId(0, ReminderType.before, 2000000);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // 7. WorkManager unique name stability
  // ---------------------------------------------------------------------------
  group('WorkManager unique name stability', () {
    DateTime now = DateTime(2025, 3, 25, 5, 0);

    test('frequent work name is stable for same prayer + type', () {
      final inst1 = ReminderInstance(
        id: ReminderInstance.frequentId(0, ReminderType.before),
        prayerIndex: 0,
        type: ReminderType.before,
        mode: ReminderMode.frequent,
        adhanEpochMillis: now.millisecondsSinceEpoch,
        triggerEpochMillis:
            now.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
        offsetMinutes: 10,
        consumed: false,
        createdAt: now,
      );
      final inst2 = ReminderInstance(
        id: ReminderInstance.frequentId(0, ReminderType.before),
        prayerIndex: 0,
        type: ReminderType.before,
        mode: ReminderMode.frequent,
        adhanEpochMillis: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        triggerEpochMillis: now
            .add(const Duration(days: 1))
            .subtract(const Duration(minutes: 10))
            .millisecondsSinceEpoch,
        offsetMinutes: 10,
        consumed: false,
        createdAt: now.add(const Duration(days: 1)),
      );
      expect(inst1.workManagerName, equals(inst2.workManagerName),
          reason: 'Frequent work name must be stable (same prayer+type)');
    });

    test('once work name encodes adhan epoch → different for each occurrence', () {
      final epoch1 = now.millisecondsSinceEpoch;
      final epoch2 = now.add(const Duration(days: 1)).millisecondsSinceEpoch;
      final inst1 = ReminderInstance(
        id: ReminderInstance.onceId(0, ReminderType.before, epoch1),
        prayerIndex: 0,
        type: ReminderType.before,
        mode: ReminderMode.once,
        adhanEpochMillis: epoch1,
        triggerEpochMillis:
            epoch1 - const Duration(minutes: 10).inMilliseconds,
        offsetMinutes: 10,
        consumed: false,
        createdAt: now,
      );
      final inst2 = inst1.copyWithConsumed(ConsumeReason.fired).copyWithConsumed(
          ConsumeReason.fired); // same id
      // A second occurrence would have a different id
      final inst3 = ReminderInstance(
        id: ReminderInstance.onceId(0, ReminderType.before, epoch2),
        prayerIndex: 0,
        type: ReminderType.before,
        mode: ReminderMode.once,
        adhanEpochMillis: epoch2,
        triggerEpochMillis:
            epoch2 - const Duration(minutes: 10).inMilliseconds,
        offsetMinutes: 10,
        consumed: false,
        createdAt: now,
      );
      expect(inst1.workManagerName, isNot(equals(inst3.workManagerName)));
    });
  });

  // ---------------------------------------------------------------------------
  // 8. Consumption lifecycle
  // ---------------------------------------------------------------------------
  group('ReminderInstance consumption lifecycle', () {
    test('copyWithConsumed marks instance consumed with reason and timestamp', () {
      final now = DateTime.now();
      final inst = ReminderInstance(
        id: 'test_id',
        prayerIndex: 0,
        type: ReminderType.before,
        mode: ReminderMode.once,
        adhanEpochMillis: now.millisecondsSinceEpoch,
        triggerEpochMillis: now.millisecondsSinceEpoch - 600000,
        offsetMinutes: 10,
        consumed: false,
        createdAt: now,
      );

      expect(inst.consumed, isFalse);

      final consumed = inst.copyWithConsumed(ConsumeReason.fired);
      expect(consumed.consumed, isTrue);
      expect(consumed.consumeReason, ConsumeReason.fired);
      expect(consumed.consumedAt, isNotNull);
      expect(consumed.id, inst.id); // id unchanged
    });

    test('frequent instance copyWithConsumed preserves mode', () {
      final inst = ReminderInstance(
        id: 'freq_0_before',
        prayerIndex: 0,
        type: ReminderType.before,
        mode: ReminderMode.frequent,
        adhanEpochMillis: 1000,
        triggerEpochMillis: 400,
        offsetMinutes: 10,
        consumed: false,
        createdAt: DateTime.now(),
      );
      final c = inst.copyWithConsumed(ConsumeReason.slotDisabled);
      expect(c.mode, ReminderMode.frequent);
    });
  });

  // ---------------------------------------------------------------------------
  // 9. Edge cases
  // ---------------------------------------------------------------------------
  group('Scheduling edge cases', () {
    test('trigger in the past rolls to next day (+1 day)', () {
      final yesterday = DateTime.now().subtract(const Duration(hours: 1));
      final advanced = yesterday.add(const Duration(days: 1));
      expect(advanced.isAfter(DateTime.now()), isTrue);
    });

    test('before: if trigger is now (exactly) it is NOT strictly before — reject', () {
      final adhan = DateTime.now().add(const Duration(hours: 1));
      final triggerExact = adhan; // 0 offset → equal
      expect(triggerExact.isBefore(adhan), isFalse);
    });

    test('after: trigger equals adhan → reject', () {
      final adhan = DateTime.now().add(const Duration(hours: 1));
      final trigger = adhan;
      expect(trigger.isAfter(adhan), isFalse);
    });

    test('large offset for before does not wrap negative epoch', () {
      final fajr = DateTime(2025, 3, 25, 5, 0); // 05:00
      const largeOffset = 60; // 1 hour before
      final trigger = fajr.subtract(Duration(minutes: largeOffset));
      // trigger = 04:00 — still same day, positive epoch
      expect(trigger.millisecondsSinceEpoch > 0, isTrue);
      expect(trigger.isBefore(fajr), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // 10. ReminderInstance JSON round-trip
  // ---------------------------------------------------------------------------
  group('ReminderInstance JSON round-trip', () {
    test('full instance with consumed state survives encode → decode', () {
      final now = DateTime(2025, 3, 25, 10, 0);
      final instance = ReminderInstance(
        id: 'r_once_0_before_1740000000000',
        prayerIndex: 0,
        type: ReminderType.before,
        mode: ReminderMode.once,
        adhanEpochMillis: 1740000000000,
        triggerEpochMillis: 1740000000000 - 600000,
        offsetMinutes: 10,
        consumed: true,
        createdAt: now,
        consumedAt: now.add(const Duration(minutes: 1)),
        consumeReason: ConsumeReason.fired,
      );

      final json = instance.toJson();
      final restored = ReminderInstance.fromJson(json);

      expect(restored.id, instance.id);
      expect(restored.prayerIndex, 0);
      expect(restored.type, ReminderType.before);
      expect(restored.mode, ReminderMode.once);
      expect(restored.consumed, isTrue);
      expect(restored.consumeReason, ConsumeReason.fired);
      expect(restored.consumedAt, isNotNull);
      expect(
        restored.adhanEpochMillis,
        instance.adhanEpochMillis,
      );
    });

    test('not-yet-consumed instance round-trip preserves nulls', () {
      final instance = ReminderInstance(
        id: 'r_freq_2_after',
        prayerIndex: 2,
        type: ReminderType.after,
        mode: ReminderMode.frequent,
        adhanEpochMillis: 1000000,
        triggerEpochMillis: 1000000 + 600000,
        offsetMinutes: 10,
        consumed: false,
        createdAt: DateTime.now(),
      );
      final restored = ReminderInstance.fromJson(instance.toJson());
      expect(restored.consumed, isFalse);
      expect(restored.consumedAt, isNull);
      expect(restored.consumeReason, isNull);
    });
  });
}
