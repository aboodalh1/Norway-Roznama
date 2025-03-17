import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/presentation/view/widgets/pray_card.dart';
import '../../../../../core/util/constant.dart';
import '../../qiblah/presentation/view/qiblah_card.dart';
import '../manger/prays_cubit.dart';

class PraysAndQiblahPage extends StatefulWidget {
  const PraysAndQiblahPage({super.key});

  @override
  State<PraysAndQiblahPage> createState() => _PraysAndQiblahPageState();
}

class _PraysAndQiblahPageState extends State<PraysAndQiblahPage> {

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<PraysCubit, PraysState>(
        listener: (context, state) {},
        builder: (context, state) {
          PraysCubit praysCubit = context.read<PraysCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "الصلاة والقبلة",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400),
              ),
              leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
            ),
            body: state is GetPraysTimesLoading || state is LocationLoadingState
                ? PrayOrLocationLoadingWidget()
                : state is GetPrayersTimesError
                    ? PraysTimesErrorWidget(error: state.error,praysCubit: praysCubit)
                    : state is LocationMissedState ||
                            state is LocationFailureState
                        ? LocationMissedWidget(praysCubit: praysCubit)
                        : Column( 
                            children: [
                              QiblahCard(),
                              SizedBox(
                                height: 15.h,
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 10.h),
                                itemBuilder: (context, index) {
                                  return PrayCard(
                                      praysCubit: praysCubit, index: index);
                                },
                                itemCount: 6,
                              )
                            ],
                          ),
          );
        },
      ),
    );
  }
}



class LocationMissedWidget extends StatelessWidget {
  const LocationMissedWidget({
    super.key,
    required this.praysCubit,
  });

  final PraysCubit praysCubit;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
              "نحتاج إلى بيانات الموقع",
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 45.h,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
                backgroundColor: WidgetStateProperty.all(
                    kPrimaryColor),
              ),
              onPressed: () {
                praysCubit.requestLocation();
              },
              child: Text(
                "سماح",
                style: TextStyle(
                    color: Colors.white, fontSize: 15.sp),
              ),
            )
          ]));
  }
}

class PraysTimesErrorWidget extends StatelessWidget {
  const PraysTimesErrorWidget({
    super.key,
    required this.praysCubit, required this.error,
  });

  final PraysCubit praysCubit;
  final String error;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error,style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w600,color: Colors.white),),
            SizedBox(
              height: 20.h,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        kPrimaryColor)),
                onPressed: () {
                  praysCubit.getPrays();
                },
                child: Text(
                  "إعادة المحاولة",
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.white),
                ))
          ],
        ),
      );
  }
}

class PrayOrLocationLoadingWidget extends StatelessWidget {
  const PrayOrLocationLoadingWidget({
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



