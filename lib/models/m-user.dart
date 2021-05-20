// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.status,
    this.result,
    this.message,
    this.error,
  });

  int? status;
  Result? result;
  String? message;
  String? error;

  factory User.fromJson(Map<String, dynamic> json) => User(
        status: json["status"] == null ? null : json["status"],
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
        message: json["message"] == null ? null : json["message"],
        error: json["error"] == null ? null : json["error"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "result": result == null ? null : result!.toJson(),
        "message": message == null ? null : message,
        "error": error == null ? null : error,
      };
}

class Result {
  Result({
    this.token,
    this.user,
  });

  String? token;
  UserClass? user;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        token: json["token"] == null ? null : json["token"],
        user: json["user"] == null ? null : UserClass.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token == null ? null : token,
        "user": user == null ? null : user!.toJson(),
      };
}

class UserClass {
  UserClass({
    this.userId,
    this.userType,
    this.firstName,
    this.lastName,
    this.mobile,
    this.hospitalName,
    this.hospitalId,
    this.patientAllocationId,
  });

  String? userId;
  int? userType;
  String? firstName;
  String? lastName;
  String? mobile;
  String? hospitalName;
  String? hospitalId;
  String? patientAllocationId;

  factory UserClass.fromJson(Map<String, dynamic> json) => UserClass(
        userId: json["user_id"] == null ? null : json["user_id"],
        userType: json["user_type"] == null ? null : json["user_type"],
        firstName: json["first_name"] == null ? null : json["first_name"],
        lastName: json["last_name"] == null ? null : json["last_name"],
        mobile: json["mobile"] == null ? null : json["mobile"],
        hospitalName: json["hospital_name"] == null ? null : json["hospital_name"],
        hospitalId: json["hospital_id"] == null ? null : json["hospital_id"],
        patientAllocationId: json["patient_allocation_id"] == null ? null : json["patient_allocation_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId == null ? null : userId,
        "user_type": userType == null ? null : userType,
        "first_name": firstName == null ? null : firstName,
        "last_name": lastName == null ? null : lastName,
        "mobile": mobile == null ? null : mobile,
        "hospital_name": hospitalName == null ? null : hospitalName,
        "hospital_id": hospitalId == null ? null : hospitalId,
        "patient_allocation_id": patientAllocationId == null ? null : patientAllocationId,
      };
}
