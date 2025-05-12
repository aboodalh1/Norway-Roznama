class PrayersModel {
  PrayersModel({
    required this.success,
    required this.message,
    required this.data,
  });
  late final bool success;
  late final String message;
  late final Data data;

  PrayersModel.fromJson(Map<String, dynamic> json){
    success = json['success'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.timings,
    required this.date,
    required this.hijriDate,
  });
  late final Timings timings;
  late final String date;
  late final String hijriDate;

  Data.fromJson(Map<String, dynamic> json){
    timings = Timings.fromJson(json['timings']);
    date = json['date'];
    hijriDate = json['hijri_date'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['timings'] = timings.toJson();
    _data['date'] = date;
    _data['hijri_date'] = hijriDate;
    return _data;
  }
}

class Timings {
  Timings({
    required this.Fajr,
    required this.Sunrise,
    required this.Dhuhr,
    required this.Asr,
    required this.AsrShadow,
    required this.Maghrib,
    required this.Isha,
  });
  late final String Fajr;
  late final String Sunrise;
  late final String Dhuhr;
  late final String Asr;
  late final String AsrShadow;
  late final String Maghrib;
  late final String Isha;

  Timings.fromJson(Map<String, dynamic> json){
    Fajr = json['Fajr'];
    Sunrise = json['Sunrise'];
    Dhuhr = json['Dhuhr'];
    Asr = json['Asr'];
    AsrShadow = json['Asr_2x_shadow'];
    Maghrib = json['Maghrib'];
    Isha = json['Isha'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Fajr'] = Fajr;
    _data['Sunrise'] = Sunrise;
    _data['Dhuhr'] = Dhuhr;
    _data['Asr'] = Asr;
    _data['Maghrib'] = Maghrib;
    _data['Isha'] = Isha;
    return _data;
  }
}