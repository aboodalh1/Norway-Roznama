
import 'package:flutter/material.dart';

class StickersErrorBody extends StatelessWidget {
  const StickersErrorBody({
    super.key,
    required this.error,
  });

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(textAlign: TextAlign.center, error));
  }
}