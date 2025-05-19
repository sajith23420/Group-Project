// lib/models/resort_model.dart

class ResortModel {
  final String resortId;
  final String name;
  final String location;
  final String description;
  final List<String>? amenities;
  final int capacityPerUnit;
  final int numberOfUnits;
  final double pricePerNightPerUnit;
  final List<String>? images;
  final String contactInfo;
  final Map<String, dynamic>? availabilityData;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResortModel({
    required this.resortId,
    required this.name,
    required this.location,
    required this.description,
    this.amenities,
    required this.capacityPerUnit,
    required this.numberOfUnits,
    required this.pricePerNightPerUnit,
    this.images,
    required this.contactInfo,
    this.availabilityData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResortModel.fromJson(Map<String, dynamic> json) {
    return ResortModel(
      resortId: json['resortId'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      capacityPerUnit: json['capacityPerUnit'] as int,
      numberOfUnits: json['numberOfUnits'] as int,
      pricePerNightPerUnit: (json['pricePerNightPerUnit'] as num).toDouble(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      contactInfo: json['contactInfo'] as String,
      availabilityData: json['availabilityData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resortId': resortId,
      'name': name,
      'location': location,
      'description': description,
      'amenities': amenities,
      'capacityPerUnit': capacityPerUnit,
      'numberOfUnits': numberOfUnits,
      'pricePerNightPerUnit': pricePerNightPerUnit,
      'images': images,
      'contactInfo': contactInfo,
      'availabilityData': availabilityData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ResortModel copyWith({
    String? resortId,
    String? name,
    String? location,
    String? description,
    List<String>? amenities,
    int? capacityPerUnit,
    int? numberOfUnits,
    double? pricePerNightPerUnit,
    List<String>? images,
    String? contactInfo,
    Map<String, dynamic>? availabilityData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResortModel(
      resortId: resortId ?? this.resortId,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      capacityPerUnit: capacityPerUnit ?? this.capacityPerUnit,
      numberOfUnits: numberOfUnits ?? this.numberOfUnits,
      pricePerNightPerUnit: pricePerNightPerUnit ?? this.pricePerNightPerUnit,
      images: images ?? this.images,
      contactInfo: contactInfo ?? this.contactInfo,
      availabilityData: availabilityData ?? this.availabilityData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// --- Request/Response Models for Resort ---

class CreateResortRequest {
  final String name;
  final String location;
  final String description;
  final List<String>? amenities;
  final int capacityPerUnit;
  final int numberOfUnits;
  final double pricePerNightPerUnit;
  final List<String>? images; // URLs if provided at creation
  final String contactInfo;
  final Map<String, dynamic>? availabilityData;

  CreateResortRequest({
    required this.name,
    required this.location,
    required this.description,
    this.amenities,
    required this.capacityPerUnit,
    required this.numberOfUnits,
    required this.pricePerNightPerUnit,
    this.images,
    required this.contactInfo,
    this.availabilityData,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'amenities': amenities ?? [],
      'capacityPerUnit': capacityPerUnit,
      'numberOfUnits': numberOfUnits,
      'pricePerNightPerUnit': pricePerNightPerUnit,
      'images': images ?? [],
      'contactInfo': contactInfo,
      'availabilityData': availabilityData ?? {},
    };
  }
}

class UpdateResortRequest {
  final String? name;
  final String? location;
  final String? description;
  final List<String>? amenities;
  final int? capacityPerUnit;
  final int? numberOfUnits;
  final double? pricePerNightPerUnit;
  final List<String>? images;
  final String? contactInfo;
  final Map<String, dynamic>? availabilityData;

  UpdateResortRequest({
    this.name,
    this.location,
    this.description,
    this.amenities,
    this.capacityPerUnit,
    this.numberOfUnits,
    this.pricePerNightPerUnit,
    this.images,
    this.contactInfo,
    this.availabilityData,
  });

   Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (location != null) data['location'] = location;
    if (description != null) data['description'] = description;
    if (amenities != null) data['amenities'] = amenities;
    if (capacityPerUnit != null) data['capacityPerUnit'] = capacityPerUnit;
    if (numberOfUnits != null) data['numberOfUnits'] = numberOfUnits;
    if (pricePerNightPerUnit != null) data['pricePerNightPerUnit'] = pricePerNightPerUnit;
    if (images != null) data['images'] = images;
    if (contactInfo != null) data['contactInfo'] = contactInfo;
    if (availabilityData != null) data['availabilityData'] = availabilityData;
    return data;
  }
}

class CheckResortAvailabilityRequest {
  final String checkInDate; // YYYY-MM-DD
  final String checkOutDate; // YYYY-MM-DD
  final int? numberOfGuests;
  final int? numberOfUnits;

  CheckResortAvailabilityRequest({
    required this.checkInDate,
    required this.checkOutDate,
    this.numberOfGuests,
    this.numberOfUnits,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
    };
    if (numberOfGuests != null) map['numberOfGuests'] = numberOfGuests as String;
    if (numberOfUnits != null) map['numberOfUnits'] = numberOfUnits as String;
    return map;
  }
}

class CheckResortAvailabilityResponse {
  final bool available;
  final int? availableUnits;
  final String message;

  CheckResortAvailabilityResponse({
    required this.available,
    this.availableUnits,
    required this.message,
  });

  factory CheckResortAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return CheckResortAvailabilityResponse(
      available: json['available'] as bool,
      availableUnits: json['availableUnits'] as int?,
      message: json['message'] as String,
    );
  }
}

class UploadResortImageResponse {
  final String message;
  final String imageUrl;
  final ResortModel resort;

  UploadResortImageResponse({
    required this.message,
    required this.imageUrl,
    required this.resort,
  });

  factory UploadResortImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadResortImageResponse(
      message: json['message'] as String,
      imageUrl: json['imageUrl'] as String,
      resort: ResortModel.fromJson(json['resort'] as Map<String, dynamic>),
    );
  }
}

class DeleteResortImageRequest {
  final String imageUrl;

  DeleteResortImageRequest({required this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
    };
  }
}

class DeleteResortImageResponse {
  final String message;
  final ResortModel resort;

   DeleteResortImageResponse({required this.message, required this.resort});

   factory DeleteResortImageResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResortImageResponse(
      message: json['message'] as String,
      resort: ResortModel.fromJson(json['resort'] as Map<String, dynamic>),
    );
  }
}