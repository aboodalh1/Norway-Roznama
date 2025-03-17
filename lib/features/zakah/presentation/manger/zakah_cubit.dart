import 'package:flutter_bloc/flutter_bloc.dart';

part 'zakah_state.dart';

class ZakahCubit extends Cubit<ZakahState> {
  ZakahCubit() : super(ZakahInitial());

  String selectedAnimal = 'أنعام'; // Default selection

  final List<Map<String, dynamic>> livestock = [
    {'name': 'انعام', 'icon': 'assets/img/anaam.png'},
    {'name': 'إبل', 'icon': 'assets/img/ebl.png'},
    {'name': 'بقر', 'icon': 'assets/img/cow.png'},
    {'name': 'غنم', 'icon': 'assets/img/sheep.png'},
  ];

}
