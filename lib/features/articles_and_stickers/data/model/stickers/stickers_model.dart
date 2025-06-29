class StickersModel {
  StickersModel({
      this.success, 
      this.message, 
      this.data, 
      this.links, 
      this.links1,
      this.meta,});

  StickersModel.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    links1 = json['links'] != null ? Links1.fromJson(json['links']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
  bool? success;
  String? message;
  List<Data>? data;
  Links? links;
  Links1? links1;
  Meta? meta;
StickersModel copyWith({  bool? success,
  String? message,
  List<Data>? data,
  Links? links,
  Meta? meta,
}) => StickersModel(  success: success ?? this.success,
  message: message ?? this.message,
  data: data ?? this.data,
  links: links ?? this.links,
  meta: meta ?? this.meta,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    if (links != null) {
      map['links'] = links?.toJson();
    }
    if (meta != null) {
      map['meta'] = meta?.toJson();
    }
    return map;
  }

}

class Meta {
  Meta({
      this.currentPage, 
      this.from, 
      this.lastPage, 
      this.links, 
      this.path, 
      this.perPage, 
      this.to, 
      this.total,});

  Meta.fromJson(dynamic json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    if (json['links'] != null) {
      links = [];
      json['links'].forEach((v) {
        links?.add(Links.fromJson(v));
      });
    }
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }
  num? currentPage;
  num? from;
  num? lastPage;
  List<Links>? links;
  String? path;
  num? perPage;
  num? to;
  num? total;
Meta copyWith({  num? currentPage,
  num? from,
  num? lastPage,
  List<Links>? links,
  String? path,
  num? perPage,
  num? to,
  num? total,
}) => Meta(  currentPage: currentPage ?? this.currentPage,
  from: from ?? this.from,
  lastPage: lastPage ?? this.lastPage,
  links: links ?? this.links,
  path: path ?? this.path,
  perPage: perPage ?? this.perPage,
  to: to ?? this.to,
  total: total ?? this.total,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    map['from'] = from;
    map['last_page'] = lastPage;
    if (links != null) {
      map['links'] = links?.map((v) => v.toJson()).toList();
    }
    map['path'] = path;
    map['per_page'] = perPage;
    map['to'] = to;
    map['total'] = total;
    return map;
  }

}

class Links {
  Links({
      this.url, 
      this.label, 
      this.active,});

  Links.fromJson(dynamic json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }
  dynamic url;
  String? label;
  bool? active;
Links copyWith({  dynamic url,
  String? label,
  bool? active,
}) => Links(  url: url ?? this.url,
  label: label ?? this.label,
  active: active ?? this.active,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['label'] = label;
    map['active'] = active;
    return map;
  }

}

class Links1 {
  Links1({
      this.first, 
      this.last, 
      this.prev, 
      this.next,});

  Links1.fromJson(dynamic json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }
  String? first;
  String? last;
  dynamic prev;
  String? next;
Links1 copyWith({  String? first,
  String? last,
  dynamic prev,
  String? next,
}) => Links1(  first: first ?? this.first,
  last: last ?? this.last,
  prev: prev ?? this.prev,
  next: next ?? this.next,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['first'] = first;
    map['last'] = last;
    map['prev'] = prev;
    map['next'] = next;
    return map;
  }

}

class Data {
  Data({
      required this.id,
    required this.url,
    required this.categoryId,
    required this.createdAt,});

  Data.fromJson(dynamic json) {
    id = json['id'] ??0;
    url = json['url']??"";
    categoryId = json['category_id']??"";
    createdAt = json['created_at']??"";
  }
  num? id;
  String? url;
  num? categoryId;
  String? createdAt;
Data copyWith({  num? id,
  String? url,
  num? categoryId,
  String? createdAt,
}) => Data(  id: id ?? this.id,
  url: url ?? this.url,
  categoryId: categoryId ?? this.categoryId,
  createdAt: createdAt ?? this.createdAt,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['url'] = url;
    map['category_id'] = categoryId;
    map['created_at'] = createdAt;
    return map;
  }

}