import 'package:flutter/material.dart';

import '../util/constant.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: kPrimaryColor,);
  }
}
