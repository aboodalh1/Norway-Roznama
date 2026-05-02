import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/prayer_reminder_config.dart';

/// A single before-or-after reminder row rendered inside the prayer expand panel.
///
/// Shows:
///   • Enable / disable switch
///   • Mode chip: "متكرر" (frequent) / "مرة واحدة" (once)
///   • Offset picker (5–60 min in steps of 5)
///
/// All changes are reported via [onSlotChanged] so the parent can call
/// [PraysCubit.updateReminderSlot].
class ReminderSlotTile extends StatefulWidget {
  const ReminderSlotTile({
    super.key,
    required this.label,
    required this.slot,
    required this.onSlotChanged,
  });

  /// Display label, e.g. "قبل الأذان" or "بعد الأذان".
  final String label;
  final ReminderSlotConfig slot;
  final ValueChanged<ReminderSlotConfig> onSlotChanged;

  @override
  State<ReminderSlotTile> createState() => _ReminderSlotTileState();
}

class _ReminderSlotTileState extends State<ReminderSlotTile> {
  late ReminderSlotConfig _slot;

  @override
  void initState() {
    super.initState();
    _slot = widget.slot;
  }

  @override
  void didUpdateWidget(ReminderSlotTile old) {
    super.didUpdateWidget(old);
    if (old.slot != widget.slot) {
      _slot = widget.slot;
    }
  }

  void _emit(ReminderSlotConfig updated) {
    setState(() => _slot = updated);
    widget.onSlotChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Row 1: label + enable switch ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff3D3D3D),
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child:                   Switch(
                    value: _slot.enabled,
                    activeThumbColor: const Color(0xFF057107),
                    onChanged: (v) => _emit(_slot.copyWith(enabled: v)),
                  ),
                ),
              ],
            ),
          ),

          // --- Offset + mode row (visible only when enabled) ---
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
              child: Row(
                children: [
                  // Offset picker
                  InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () => _showOffsetPicker(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xff889CB8)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${_slot.offsetMinutes} دقيقة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff535763),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Mode toggle chips
                  _ModeChip(
                    label: 'متكرر',
                    selected: _slot.mode == ReminderMode.frequent,
                    onTap: () =>
                        _emit(_slot.copyWith(mode: ReminderMode.frequent)),
                  ),
                  SizedBox(width: 8.w),
                  _ModeChip(
                    label: 'مرة واحدة',
                    selected: _slot.mode == ReminderMode.once,
                    onTap: () =>
                        _emit(_slot.copyWith(mode: ReminderMode.once)),
                  ),
                ],
              ),
            ),
            crossFadeState: _slot.enabled
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  void _showOffsetPicker(BuildContext context) {
    // Allowed offsets: 5, 10, 15, 20, 30, 45, 60 minutes.
    const List<int> offsets = [5, 10, 15, 20, 30, 45, 60];
    showDialog<int>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'اختر الوقت',
            style: TextStyle(fontSize: 16.sp),
          ),
          content: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: offsets.map((minutes) {
              final bool isSelected = _slot.offsetMinutes == minutes;
              return                   ChoiceChip(
                    label: Text('$minutes د'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF057107).withValues(alpha: 0.2),
                    onSelected: (_) {
                  Navigator.pop(ctx, minutes);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    ).then((value) {
      if (value != null) {
        _emit(_slot.copyWith(offsetMinutes: value));
      }
    });
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF057107).withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? const Color(0xFF057107)
                : const Color(0xff889CB8),
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? const Color(0xFF057107)
                : const Color(0xff535763),
          ),
        ),
      ),
    );
  }
}
