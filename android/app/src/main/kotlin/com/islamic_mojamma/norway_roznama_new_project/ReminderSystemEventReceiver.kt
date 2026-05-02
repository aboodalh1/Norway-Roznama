package com.islamic_mojamma.norway_roznama_new_project

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Receives system broadcasts that may invalidate scheduled reminder timings and
 * signals to the Flutter layer that a full reconciliation is needed on next launch.
 *
 * Handled intents:
 *  - BOOT_COMPLETED / QUICKBOOT_POWERON   → device rebooted.
 *  - MY_PACKAGE_REPLACED                  → app was updated.
 *  - ACTION_TIMEZONE_CHANGED              → timezone shifted; existing delays may be stale.
 *  - ACTION_TIME_SET                      → manual clock change.
 *
 * Strategy: write a flag to the Flutter SharedPreferences file
 * ("FlutterSharedPreferences") so PraysCubit picks it up on the next cold start
 * and calls _rescheduleAllReminders(). WorkManager already survives reboots via its
 * own boot receiver; this flag handles the rarer cases where the reminder trigger
 * times themselves must be recomputed (timezone / manual clock changes).
 *
 * The key is stored as "flutter.reminder_needs_reconcile" which maps directly to
 * CacheHelper.getData(key: 'reminder_needs_reconcile') in Dart.
 */
class ReminderSystemEventReceiver : BroadcastReceiver() {

    companion object {
        /** Flutter SharedPreferences file name (set by shared_preferences_android plugin). */
        private const val FLUTTER_PREFS_FILE = "FlutterSharedPreferences"

        /**
         * Flag key (with the "flutter." prefix that the Dart plugin adds).
         * Dart: CacheHelper.getData(key: 'reminder_needs_reconcile')
         */
        private const val FLAG_KEY = "flutter.reminder_needs_reconcile"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return

        val shouldFlag = action in setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
        )

        if (!shouldFlag) return

        android.util.Log.d(
            "ReminderSystemEventReceiver",
            "Received $action — flagging reminder reconciliation needed."
        )

        try {
            val prefs = context.getSharedPreferences(FLUTTER_PREFS_FILE, Context.MODE_PRIVATE)
            prefs.edit().putBoolean(FLAG_KEY, true).apply()
            android.util.Log.d(
                "ReminderSystemEventReceiver",
                "Reminder reconcile flag written to $FLUTTER_PREFS_FILE."
            )
        } catch (e: Exception) {
            android.util.Log.e(
                "ReminderSystemEventReceiver",
                "Failed to write reconcile flag: ${e.message}"
            )
        }
    }
}
