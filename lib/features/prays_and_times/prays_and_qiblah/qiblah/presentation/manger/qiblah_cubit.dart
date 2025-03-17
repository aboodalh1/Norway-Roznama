import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/qiblah/data/repos/qiblah_repo.dart';

part 'qiblah_state.dart';

class QiblahCubit extends Cubit<QiblahState> {
  QiblahCubit(this.qiblahRepo) : super(QiblahInitial()){
   fetchLocation();
  }
  QiblahRepo qiblahRepo;
  Uint8List? imageData;
  Future<void> getQiblah()async {
    emit(GetQiblahLoading());
    var result = await qiblahRepo.getQiblah();
    result.fold((failure) {
      emit(GetQiblahFailure(error: failure.errMessage));
    },
            (response)
    {
      imageData=response.data;
      emit(GetQiblahSuccess(message: 'message'));
    }
    );

  }



}
