import '../blogs_model.dart';

class CategoriesModel {
  CategoriesModel({
    required this.data,
    required this.links,
    required this.meta,
  });
  late final List<Data> data;
  late final Links links;
  late final Meta meta;

  CategoriesModel.fromJson(Map<String, dynamic> json){
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
    links = Links.fromJson(json['links']);
    meta = Meta.fromJson(json['meta']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data.map((e)=>e.toJson()).toList();
    _data['links'] = links.toJson();
    _data['meta'] = meta.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.id,
    required this.name,
    required this.stickers,
    required this.createdAt,
  });
  late final int id;
  late final String name;
  late final List<Stickers> stickers;
  late final String createdAt;

  Data.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    stickers = List.from(json['stickers']).map((e)=>Stickers.fromJson(e)).toList();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['stickers'] = stickers.map((e)=>e.toJson()).toList();
    _data['created_at'] = createdAt;
    return _data;
  }
}

class Stickers {
  Stickers({
    required this.id,
    required this.name,
    required this.url,
    required this.categoryId,
    required this.createdAt,
  });
  late final int id;
  bool isSelected = false;
  late final String name;
  late final String url;
  late final int categoryId;
  late final String createdAt;

  Stickers.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name']??"";
    url = json['url']??"";
    categoryId = json['category_id']??"";
    createdAt = json['created_at']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['url'] = url;
    _data['category_id'] = categoryId;
    _data['created_at'] = createdAt;
    return _data;
  }
}
