import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repos/advice_repo.dart';

part 'advice_state.dart';

class AdviceCubit extends Cubit<AdviceState> {
  AdviceCubit(this.adviceRepo) : super(AdviceInitial());
  AdviceRepo adviceRepo;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  Future<void> sentAdvice() async {
    if(nameController.text.isEmpty || emailController.text.isEmpty || messageController.text.isEmpty){
      emit(SentValidationFailure(error: 'الرجاء تعبئة جميع الحقول'));
    }
    else if(nameController.text.length<3){
      emit(SentValidationFailure(error: 'الاسم يجب ان يتكون من ثلاثة محارف على الأقل'));
    }
    else if(nameController.text.length>255){
      emit(SentValidationFailure(error: 'الاسم يجب ان يكون اقل من مئتان محرف'));
    }
    else if(messageController.text.length<3){
      emit(SentValidationFailure(error: 'النصيحة يجب ان تتكون من ثلاثة محارف على الأقل'));
    }
    else if(messageController.text.length>255){
      emit(SentValidationFailure(error: 'لا يمكن ان تكون النصيحة اكثر من ألف محرف'));
    }
    else{
    emit(SentAdviceLoading());
    var response = await adviceRepo.sentAdvice(
        name: nameController.text,
        email: emailController.text,
        message: messageController.text);
    response.fold((l) {
      emit(SentAdviceFailure(error: l.errMessage));
    }, (r) {
      emit(SentAdviceSuccess(message: r.data['message']));
    });
  }}
}
