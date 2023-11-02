
class UserResponse {
  String? message;
  String? token;
  User? user;
  Client? client;

  UserResponse({this.message, this.token, this.user, this.client});

  UserResponse.fromJson(Map<String, dynamic> json) {
    if(json["message"] is String) {
      message = json["message"];
    }
    if(json["token"] is String) {
      token = json["token"];
    }
    if(json["user"] is Map) {
      user = json["user"] == null ? null : User.fromJson(json["user"]);
    }
    if(json["client"] is Map) {
      client = json["client"] == null ? null : Client.fromJson(json["client"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["message"] = message;
    _data["token"] = token;
    if(user != null) {
      _data["user"] = user?.toJson();
    }
    if(client != null) {
      _data["client"] = client?.toJson();
    }
    return _data;
  }
}

class Client {
  String? idClient;
  String? idUser;
  int? status;
  String? createdAt;
  String? updatedAt;

  Client({this.idClient, this.idUser, this.status, this.createdAt, this.updatedAt});

  Client.fromJson(Map<String, dynamic> json) {
    if(json["id_client"] is String) {
      idClient = json["id_client"];
    }
    if(json["id_user"] is String) {
      idUser = json["id_user"];
    }
    if(json["status"] is int) {
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
    _data["id_user"] = idUser;
    _data["status"] = status;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}

class User {
  String? idUser;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? level;
  String? createdAt;
  String? updatedAt;

  User({this.idUser, this.name, this.email, this.emailVerifiedAt, this.level, this.createdAt, this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    if(json["id_user"] is String) {
      idUser = json["id_user"];
    }
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["email"] is String) {
      email = json["email"];
    }
    emailVerifiedAt = json["email_verified_at"];
    if(json["level"] is String) {
      level = json["level"];
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
    _data["id_user"] = idUser;
    _data["name"] = name;
    _data["email"] = email;
    _data["email_verified_at"] = emailVerifiedAt;
    _data["level"] = level;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}