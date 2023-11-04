
class ClientResponse {
  String? idResponse;
  String? message;
  String? type;
  int? status;
  int? perpage;
  int? page;
  int? total;
  List<Data>? data;

  ClientResponse({this.idResponse, this.message, this.type, this.status, this.perpage, this.page, this.total, this.data});

  ClientResponse.fromJson(Map<String, dynamic> json) {
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
  String? clientName;
  String? email;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data({this.idClient, this.clientName, this.email, this.status, this.createdAt, this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    if(json["id_client"] is String) {
      idClient = json["id_client"];
    }
    if(json["client_name"] is String) {
      clientName = json["client_name"];
    }
    if(json["email"] is String) {
      email = json["email"];
    }
    if(json["status"] is String) {
      status = json["status"];
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
    _data["client_name"] = clientName;
    _data["email"] = email;
    _data["status"] = status;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}