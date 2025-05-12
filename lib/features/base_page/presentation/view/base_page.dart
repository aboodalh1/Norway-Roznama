import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../prays_and_times/prays_and_qiblah/presentation/manger/prays_cubit.dart';
import 'base_page_body.dart';
import 'base_page_loading_state.dart';
import 'base_page_location_missed.dart';
import 'base_page_prays_error.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key, required this.context1});

  final BuildContext context1;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PraysCubit, PraysState>(
      listener: (context, state) {},
      builder: (context, state) {
        PraysCubit praysCubit = context.read<PraysCubit>();
        return Scaffold(
          appBar: AppBar(),
          body: state is GetPraysTimesLoading || state is LocationLoadingState
              ? BasePageLoadingState()
              : state is GetPrayersTimesError
                  ? BasePagePraysError(
                      praysCubit: praysCubit,
                      error: state.error,
                    )
                  : state is LocationMissedState ||
                          state is LocationFailureState
                      ? BasePageLocationMissed(praysCubit: praysCubit)
                      : BasePageBody(praysCubit: praysCubit),
        );
      },
    );
  }
}
