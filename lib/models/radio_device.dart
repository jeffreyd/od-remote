import 'dart:convert';

class RadioDevice {
  final String id;
  final String name;
  final String host;

  RadioDevice({required this.id, required this.name, required this.host});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'host': host};

  factory RadioDevice.fromJson(Map<String, dynamic> json) => RadioDevice(
    id: json['id'] as String,
    name: json['name'] as String,
    host: json['host'] as String,
  );

  static List<RadioDevice> listFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => RadioDevice.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<RadioDevice> radios) =>
      jsonEncode(radios.map((r) => r.toJson()).toList());

  RadioDevice copyWith({String? name, String? host}) =>
      RadioDevice(id: id, name: name ?? this.name, host: host ?? this.host);
}
