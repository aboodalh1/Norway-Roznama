import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:norway_roznama_new_project/features/halal_food/data/model/halal_model.dart';
import 'package:norway_roznama_new_project/features/halal_food/data/repos/halal_repo.dart';

part 'halal_state.dart';

class HalalCubit extends Cubit<HalalState> {
  HalalCubit(this.halalRepo) : super(HalalInitial());
  HalalRepo halalRepo;
  Barcode? barcode;
  bool ?isHalal;

MobileScannerController cameraController = MobileScannerController(
  detectionSpeed: DetectionSpeed.noDuplicates,
  facing: CameraFacing.back,
  torchEnabled: false, 
);
HalalModel halalModel = HalalModel();
  void handleBarcode(BarcodeCapture barcodes) async{
    cameraController.pause();
    emit(HalalLoading());
    barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null) {
      if(barcode!.displayValue!=null){
      var result = await halalRepo.checkHalal(barcode: barcode!.displayValue!);
            result.fold(
                    (failure){
                      emit(HalalFailure(error: failure.errMessage));
                    },
                    (response){
                      halalModel = HalalModel.fromJson(response.data);
                      if(halalModel.data!.product!.isHalal==null) {
                        emit(HalalFailure(error: "هذا المنتج غير معروف"));
                      }
                      isHalal=halalModel.data!.product!.isHalal;
                    });
          emit(HalalSuccess());
        }
    }
  }
}
