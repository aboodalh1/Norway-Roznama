class HalalModel {
  HalalModel({
      this.success, 
      this.message, 
      this.data,});

  HalalModel.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? success;
  String? message;
  Data? data;
HalalModel copyWith({  bool? success,
  String? message,
  Data? data,
}) => HalalModel(  success: success ?? this.success,
  message: message ?? this.message,
  data: data ?? this.data,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }

}

class Data {
  Data({
      this.product, 
      this.source, 
      this.url,});

  Data.fromJson(dynamic json) {
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    source = json['source'];
    url = json['url'];
  }
  Product? product;
  String? source;
  String? url;
Data copyWith({  Product? product,
  String? source,
  String? url,
}) => Data(  product: product ?? this.product,
  source: source ?? this.source,
  url: url ?? this.url,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (product != null) {
      map['product'] = product?.toJson();
    }
    map['source'] = source;
    map['url'] = url;
    return map;
  }

}

class Product {
  Product({
      this.name, 
      this.isHalal, 
      this.label,});

  Product.fromJson(dynamic json) {
    name = json['name'];
    isHalal = json['is_halal'];
    label = json['label'];
  }
  String? name;
  bool? isHalal;
  String? label;
Product copyWith({  String? name,
  bool? isHalal,
  String? label,
}) => Product(  name: name ?? this.name,
  isHalal: isHalal ?? this.isHalal,
  label: label ?? this.label,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['is_halal'] = isHalal;
    map['label'] = label;
    return map;
  }

}