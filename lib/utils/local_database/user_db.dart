// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserDB {
  String? name;
  String? description;
  List<String>? history;
  bool? isPermissionGranted;
  UserDB({
    this.name,
    this.description,
    this.history,
    this.isPermissionGranted,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'history': history,
      'isPermissionGranted': isPermissionGranted,
    };
  }

  factory UserDB.fromMap(Map<String, dynamic> map) {
    return UserDB(
      name: map['name'] != null ? map['name'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      history:
          map['history'] != null ? List<String>.from((map['history'])) : null,
      isPermissionGranted: map['isPermissionGranted'] != null
          ? map['isPermissionGranted'] as bool
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDB.fromJson(String source) {
    if (source != "") {
      return UserDB.fromMap(json.decode(source) as Map<String, dynamic>);
    }
    return UserDB();
  }
}
