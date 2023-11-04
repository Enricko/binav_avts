
class KapalResponse {
  String? idResponse;
  String? message;
  String? type;
  int? status;
  int? perpage;
  int? page;
  int? total;
  List<Data>? data;

  KapalResponse({this.idResponse, this.message, this.type, this.status, this.perpage, this.page, this.total, this.data});

  KapalResponse.fromJson(Map<String, dynamic> json) {
    if(json["id_response"] is String) {
      idResponse = json["id_response"];
    }
    if(json["message"] is String) {
      message = json["message"];
    }
    if(json["type"] is String) {
      type = json["type"];
    }
    if(json["status"] is int) {
      status = json["status"];
    }
    if(json["perpage"] is int) {
      perpage = json["perpage"];
    }
    if(json["page"] is int) {
      page = json["page"];
    }
    if(json["total"] is int) {
      total = json["total"];
    }
    if(json["data"] is List) {
      data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id_response"] = idResponse;
    _data["message"] = message;
    _data["type"] = type;
    _data["status"] = status;
    _data["perpage"] = perpage;
    _data["page"] = page;
    _data["total"] = total;
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  String? idClient;
  String? callSign;
  String? flag;
  String? kelas;
  String? builder;
  String? size;
  bool? status;
  String? xmlFile;
  String? yearBuilt;
  String? createdAt;
  String? updatedAt;

  Data({this.idClient, this.callSign, this.flag, this.kelas, this.builder, this.size, this.status, this.xmlFile, this.yearBuilt, this.createdAt, this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    if(json["id_client"] is String) {
      idClient = json["id_client"];
    }
    if(json["call_sign"] is String) {
      callSign = json["call_sign"];
    }
    if(json["flag"] is String) {
      flag = json["flag"];
    }
    if(json["kelas"] is String) {
      kelas = json["kelas"];
    }
    if(json["builder"] is String) {
      builder = json["builder"];
    }
    if(json["size"] is String) {
      size = json["size"];
    }
    if(json["status"] is bool) {
      status = json["status"];
    }
    if(json["xml_file"] is String) {
      xmlFile = json["xml_file"];
    }
    if(json["year_built"] is String) {
      yearBuilt = json["year_built"];
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if(json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id_client"] = idClient;
    _data["call_sign"] = callSign;
    _data["flag"] = flag;
    _data["kelas"] = kelas;
    _data["builder"] = builder;
    _data["size"] = size;
    _data["status"] = status;
    _data["xml_file"] = xmlFile;
    _data["year_built"] = yearBuilt;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}