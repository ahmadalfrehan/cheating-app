import 'dart:convert';

/// Main response model
class ClassesResponse {
  final bool status;
  final String message;
  final ClassesData data;

  ClassesResponse.name(this.status, this.message, this.data);

  ClassesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ClassesResponse.fromJson(Map<String, dynamic> json) {
    return ClassesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ClassesData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }

  /// Helper to parse from raw string
  static ClassesResponse fromRawJson(String str) =>
      ClassesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// Data object that contains counts and class list
class ClassesData {
  final int numberOfActiveClasses;
  final List<ClassItem> classes;

  ClassesData({required this.numberOfActiveClasses, required this.classes});

  factory ClassesData.fromJson(Map<String, dynamic> json) {
    return ClassesData(
      numberOfActiveClasses: json['number_of_active_classes'] ?? 0,
      classes:
          (json['classes'] as List<dynamic>)
              .map((e) => ClassItem.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number_of_active_classes': numberOfActiveClasses,
      'classes': classes.map((e) => e.toJson()).toList(),
    };
  }
}

/// Individual class item
class ClassItem {
  final int id;
  final String name;
  final int capacity;
  final int instituteId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ClassItem({
    required this.id,
    required this.name,
    required this.capacity,
    required this.instituteId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
      instituteId: json['institute_id'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'institute_id': instituteId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
