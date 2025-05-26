// lib/models/officer_model.dart

class OfficerModel {
  final String officerId;
  final String name;
  final String designation;
  final String assignedPostOfficeId;
  final String? contactNumber;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfficerModel({
    required this.officerId,
    required this.name,
    required this.designation,
    required this.assignedPostOfficeId,
    this.contactNumber,
    this.email,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfficerModel.fromJson(Map<String, dynamic> json) {
    return OfficerModel(
      officerId: json['officerId'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String,
      assignedPostOfficeId: json['assignedPostOfficeId'] as String,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'officerId': officerId,
      'name': name,
      'designation': designation,
      'assignedPostOfficeId': assignedPostOfficeId,
      'contactNumber': contactNumber,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

   OfficerModel copyWith({
    String? officerId,
    String? name,
    String? designation,
    String? assignedPostOfficeId,
    String? contactNumber,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfficerModel(
      officerId: officerId ?? this.officerId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      assignedPostOfficeId: assignedPostOfficeId ?? this.assignedPostOfficeId,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// --- Request Models for Officer ---

class CreateOfficerRequest {
  final String name;
  final String designation;
  final String assignedPostOfficeId;
  final String? contactNumber;
  final String? email;
  final String? photoUrl;

  CreateOfficerRequest({
    required this.name,
    required this.designation,
    required this.assignedPostOfficeId,
    this.contactNumber,
    this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'designation': designation,
      'assignedPostOfficeId': assignedPostOfficeId,
    };
    if (contactNumber != null) map['contactNumber'] = contactNumber as String;
    if (email != null) map['email'] = email as String;
    if (photoUrl != null) map['photoUrl'] = photoUrl as String;
    return map;
  }
}

class UpdateOfficerRequest {
  final String? name;
  final String? designation;
  final String? assignedPostOfficeId;
  final String? contactNumber;
  final String? email;
  final String? photoUrl;

  UpdateOfficerRequest({
    this.name,
    this.designation,
    this.assignedPostOfficeId,
    this.contactNumber,
    this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (designation != null) data['designation'] = designation;
    if (assignedPostOfficeId != null) data['assignedPostOfficeId'] = assignedPostOfficeId;
    if (contactNumber != null) data['contactNumber'] = contactNumber;
    if (email != null) data['email'] = email;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    return data;
  }
}