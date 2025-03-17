import 'package:flutter/material.dart';

import '../../../../core/util/constant.dart';

class StickerLoadingBody extends StatelessWidget {
  const StickerLoadingBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
        ));
  }
}

