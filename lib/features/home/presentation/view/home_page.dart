import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/features/base_page/presentation/view/base_page.dart';
import 'package:norway_roznama_new_project/features/home/presentation/view/widgets/custom_bottom_nav_bar.dart';
import '../../../articles_and_stickers/presentation/view/articles_page.dart';
import '../../../halal_food/presentation/view/halal_page.dart';
import '../manger/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            HomeCubit homeCubit = context.read<HomeCubit>();
            return Scaffold(
              bottomNavigationBar: CustomBottomNavBar(homeCubit: homeCubit),
              body: context.read<HomeCubit>().currentIndex == 0
                  ? BasePage(context1: context,)
                  : context.read<HomeCubit>().currentIndex == 1
                      ? const ArticlesAndStickersPage()
                      : const HalalPage(),
            );
          },
        ),
      ),
    );
  }
}


