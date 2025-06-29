import 'package:flutter/material.dart';

import '../util/constant.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    super.key, required this.function, required this.switchValue,
  });
  final ValueChanged<bool> function;
  final bool switchValue ;
  @override
  Widget build(BuildContext context) {
    return Switch(
        activeTrackColor: kPinkColor,
        activeColor: kPinkColor,
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
                (states) {
              if (states.contains(WidgetState.disabled)) {
                return Color(0xff7F7F7F);
              }
              if (states.contains(WidgetState.selected)) {
                return kPinkColor;
              }
              else{
                return Color(0xff7F7F7F);
              }
            }
        ),
        value: switchValue,
        onChanged: function
    );
  }
}