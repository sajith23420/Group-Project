// lib/models/post_office_model.dart

import 'package:post_app/models/enums.dart';

class PostOfficeModel {
  final String postOfficeId;
  final String name;
  final String postalCode;
  final String address;
  final String? contactNumber;
  final String? postmasterName;
  final List<String>? subPostOfficeIds;
  final List<PostOfficeService> servicesOffered;
  final dynamic
      operatingHours; // Can be String or Map, backend uses Joi.alternatives
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostOfficeModel({
    required this.postOfficeId,
    required this.name,
    required this.postalCode,
    required this.address,
    this.contactNumber,
    this.postmasterName,
    this.subPostOfficeIds,
    required this.servicesOffered,
    required this.operatingHours,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostOfficeModel.fromJson(Map<String, dynamic> json) {
    return PostOfficeModel(
      postOfficeId: json['postOfficeId'] as String,
      name: json['name'] as String,
      postalCode: json['postalCode'] as String,
      address: json['address'] as String,
      contactNumber: json['contactNumber'] as String?,
      postmasterName: json['postmasterName'] as String?,
      subPostOfficeIds: (json['subPostOfficeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      servicesOffered: (json['servicesOffered'] as List<dynamic>)
          .map((e) => PostOfficeService.fromJson(e as String))
          .toList(),
      operatingHours: json['operatingHours'], // Keep as dynamic
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postOfficeId': postOfficeId,
      'name': name,
      'postalCode': postalCode,
      'address': address,
      'contactNumber': contactNumber,
      'postmasterName': postmasterName,
      'subPostOfficeIds': subPostOfficeIds,
      'servicesOffered': servicesOffered.map((e) => e.toJson()).toList(),
      'operatingHours': operatingHours,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PostOfficeModel copyWith({
    String? postOfficeId,
    String? name,
    String? postalCode,
    String? address,
    String? contactNumber,
    String? postmasterName,
    List<String>? subPostOfficeIds,
    List<PostOfficeService>? servicesOffered,
    dynamic operatingHours,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostOfficeModel(
      postOfficeId: postOfficeId ?? this.postOfficeId,
      name: name ?? this.name,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      postmasterName: postmasterName ?? this.postmasterName,
      subPostOfficeIds: subPostOfficeIds ?? this.subPostOfficeIds,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      operatingHours: operatingHours ?? this.operatingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// --- Request/Response Models for Post Office ---

class CreatePostOfficeRequest {
  final String name;
  final String postalCode;
  final String address;
  final String? contactNumber;
  final String? postmasterName;
  final List<String>? subPostOfficeIds;
  final List<String> servicesOffered; // Send as List<String>
  final dynamic operatingHours;
  final double latitude;
  final double longitude;

  CreatePostOfficeRequest({
    required this.name,
    required this.postalCode,
    required this.address,
    this.contactNumber,
    this.postmasterName,
    this.subPostOfficeIds,
    required this.servicesOffered,
    required this.operatingHours,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'postalCode': postalCode,
      'address': address,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (postmasterName != null) 'postmasterName': postmasterName,
      'subPostOfficeIds': subPostOfficeIds ?? [],
      'servicesOffered': servicesOffered,
      'operatingHours': operatingHours,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UpdatePostOfficeRequest {
  final String? name;
  final String? postalCode;
  final String? address;
  final String? contactNumber;
  final String? postmasterName;
  final List<String>? subPostOfficeIds;
  final List<String>? servicesOffered;
  final dynamic operatingHours;
  final double? latitude;
  final double? longitude;

  UpdatePostOfficeRequest({
    this.name,
    this.postalCode,
    this.address,
    this.contactNumber,
    this.postmasterName,
    this.subPostOfficeIds,
    this.servicesOffered,
    this.operatingHours,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (postalCode != null) data['postalCode'] = postalCode;
    if (address != null) data['address'] = address;
    if (contactNumber != null) data['contactNumber'] = contactNumber;
    if (postmasterName != null) data['postmasterName'] = postmasterName;
    if (subPostOfficeIds != null) data['subPostOfficeIds'] = subPostOfficeIds;
    if (servicesOffered != null) data['servicesOffered'] = servicesOffered;
    if (operatingHours != null) data['operatingHours'] = operatingHours;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    return data;
  }
}
