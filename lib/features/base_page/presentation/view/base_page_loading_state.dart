import 'package:flutter/material.dart';

import '../../../../core/util/constant.dart';

class BasePageLoadingState extends StatelessWidget {
  const BasePageLoadingState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: kPrimaryColor,
      ),
    );
  }
}