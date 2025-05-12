class MonthlyTimingModel {
  MonthlyTimingModel({
    required this.success,
    required this.message,
    required this.data,
  });
  late final bool success;
  late final String message;
  late final List<Data> data;

  MonthlyTimingModel.fromJson(Map<String, dynamic> json){
    success = json['success'];
    message = json['message'];
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Data {
  Data({
    required this.timings,
    required this.date,
    required this.day,
    required this.hijriDate,
    required this.location,
  });
  late final Timings timings;
  late final String date;
  late final String hijriDate;
  late final String day;
  late final String location;

  Data.fromJson(Map<String, dynamic> json){
    timings = Timings.fromJson(json['timings']);
    date = json['date'];
    day = json['day'];
    hijriDate = json['hijri_date'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['timings'] = timings.toJson();
    _data['date'] = date;
    _data['day'] = day;
    _data['hijri_date'] = hijriDate;
    _data['location'] = location;
    return _data;
  }
}

class Timings {
  Timings({
    required this.Fajr,
    required this.Sunrise,
    required this.Dhuhr,
    required this.Asr_1xShadow,
    required this.Asr,
    required this.Maghrib,
    required this.Isha,
  });
  late final String Fajr;
  late final String Sunrise;
  late final String Dhuhr;
  late final String Asr_1xShadow;
  late final String Asr;
  late final String Maghrib;
  late final String Isha;

  Timings.fromJson(Map<String, dynamic> json){
    Fajr = json['Fajr'];
    Sunrise = json['Sunrise'];
    Dhuhr = json['Dhuhr'];
    Asr_1xShadow = json['Asr_1x_shadow'];
    Asr = json['Asr'];
    Maghrib = json['Maghrib'];
    Isha = json['Isha'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Fajr'] = Fajr;
    _data['Sunrise'] = Sunrise;
    _data['Dhuhr'] = Dhuhr;
    _data['Asr_1x_shadow'] = Asr_1xShadow;
    _data['Asr'] = Asr;
    _data['Maghrib'] = Maghrib;
    _data['Isha'] = Isha;
    return _data;
  }
}