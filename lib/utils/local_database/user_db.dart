import 'dart:convert';

class UserDB {
  String? name;
  String? description;
  List<String> url;
  UserDB({required this.name, required this.description, required this.url}) {
    name = name;
    description = description;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'url': url,
    };
  }

  factory UserDB.fromMap(Map<String, dynamic> map) {
    return UserDB(
        name: map['name'] != null ? map['name'] as String : null,
        description:
            map['description'] != null ? map['description'] as String : null,
        url: List<String>.from(
          (map['url']),
        ));
  }

  String toJson() => json.encode(toMap());

  factory UserDB.fromJson(String source) =>
      UserDB.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Model(name: $name, description: $description, url: $url)';
}
