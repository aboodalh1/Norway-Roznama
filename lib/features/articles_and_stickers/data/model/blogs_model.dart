class AllBlogsModel {
  AllBlogsModel({
    required this.data,
    required this.links,
    required this.meta,
  });
  late final List<Data> data;
  late final Links links;
  late final Meta meta;

  AllBlogsModel.fromJson(Map<String, dynamic> json){
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
    required this.title,
    required this.content,
    required this.images,
    required this.createdAt,
  });
  late final int id;
  late final String title;
  late final String content;
  late final String htmlFreeContent;
  late final List<Images> images;
  late final String createdAt;

  Data.fromJson(Map<String, dynamic> json){
    id = json['id'];
    title = json['title'];
    content = json['content'];
    htmlFreeContent = json['html_free_content'];
    images = List.from(json['images']).map((e)=>Images.fromJson(e)).toList();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['title'] = title;
    _data['content'] = content;
    _data['html_free_content'] = htmlFreeContent;
    _data['images'] = images.map((e)=>e.toJson()).toList();
    _data['created_at'] = createdAt;
    return _data;
  }
}

class Images {
  Images({
    required this.url,
  });
  late final String url;

  Images.fromJson(Map<String, dynamic> json){
    url = json['url']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['url'] = url;
    return _data;
  }
}

class Links {
  Links({
    required this.first,
    required this.last,
    required this.prev,
    required this.next,
  });
  late final String first;
  late final String last;
  late final String prev;
  late final String next;

  Links.fromJson(Map<String, dynamic> json){
    first = json['first']??"";
    last = json['last']??"";
    prev = json['prev']??"";
    next = json['next']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['first'] = first;
    _data['last'] = last;
    _data['prev'] = prev;
    _data['next'] = next;
    return _data;
  }
}

class Meta {
  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });
  late final int currentPage;
  late final int from;
  late final int lastPage;
  late final List<Links> links;
  late final String path;
  late final int perPage;
  late final int to;
  late final int total;

  Meta.fromJson(Map<String, dynamic> json){
    currentPage = json['current_page'];
    from = json['from']??0;
    lastPage = json['last_page'];
    links = List.from(json['links']).map((e)=>Links.fromJson(e)).toList();
    path = json['path'];
    perPage = json['per_page'];
    to = json['to']??0;
    total = json['total'];
  }
  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['current_page'] = currentPage;
    _data['from'] = from;
    _data['last_page'] = lastPage;
    _data['links'] = links.map((e)=>e.toJson()).toList();
    _data['path'] = path;
    _data['per_page'] = perPage;
    _data['to'] = to;
    _data['total'] = total;
    return _data;
  }
}