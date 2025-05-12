import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:norway_roznama_new_project/features/halal_food/data/repos/halal_repo_impl.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/data/repos/monthly_timing_repo_impl.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/qiblah/data/repos/qiblah_repo_impl.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/adhan_repo_impl.dart';

import '../../features/advice/data/repos/advice_repo_impl.dart';
import '../../features/articles_and_stickers/data/repos/articles_repo_impl.dart';
import '../../features/articles_and_stickers/data/repos/stickers_repos/stickers_repo_impl.dart';
import '../../features/prays_and_times/prays_and_qiblah/data/repos/prays_repo_impl.dart';
import 'api_service.dart';


final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton(DioHelper(Dio()));
  getIt.registerSingleton<ArticlesRepoImpl>(ArticlesRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<HalalRepoImpl>(HalalRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<StickersRepoImpl>(StickersRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<AdviceRepoImpl>(AdviceRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<PraysRepoImpl>(PraysRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<QiblahRepoImpl>(QiblahRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<AdhanRepoImpl>(AdhanRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<MonthlyTimingRepoImpl>(MonthlyTimingRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton(Is24Format());
}