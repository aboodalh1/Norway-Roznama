import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'halal_state.dart';

class HalalCubit extends Cubit<HalalState> {
  HalalCubit() : super(HalalInitial());

  Barcode? barcode;
  bool ?isHalal;



  void handleBarcode(BarcodeCapture barcodes) {
    barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null) {
      if(barcode!.displayValue!=null){
        if(barcode!.displayValue!.startsWith(RegExp(r'^[4..7]$'))){
          isHalal=true;
          emit(HalalSuccess());
        }
        else {
          isHalal=false;
          emit(HalalFailure());
        }
      }
    }
  }
}
