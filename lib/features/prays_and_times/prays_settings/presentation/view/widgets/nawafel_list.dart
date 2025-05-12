import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'nafela_tile.dart';



class NawafelList extends StatelessWidget {
  const NawafelList({
    super.key,
  });
   
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListView.separated(
          physics:
          const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return NafelaTile(
                index:index,
                );
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 0.5.h,
              color: const Color(0xff889CB8),
            );
          },
          itemCount: 5),
    );
  }
}
