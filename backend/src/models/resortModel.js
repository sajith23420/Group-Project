class Resort {
  constructor(
    resortId,
    name,
    location,
    description,
    amenities,
    capacityPerUnit,
    numberOfUnits,
    pricePerNightPerUnit,
    images,
    contactInfo,
    availabilityData = {}
  ) {
    this.resortId = resortId;
    this.name = name;
    this.location = location;
    this.description = description;
    this.amenities = amenities || [];
    this.capacityPerUnit = Number(capacityPerUnit);
    this.numberOfUnits = Number(numberOfUnits);
    this.pricePerNightPerUnit = Number(pricePerNightPerUnit);
    this.images = images || [];
    this.contactInfo = contactInfo;
    this.availabilityData = availabilityData;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new Resort(
      doc.id,
      data.name,
      data.location,
      data.description,
      data.amenities,
      data.capacityPerUnit,
      data.numberOfUnits,
      data.pricePerNightPerUnit,
      data.images,
      data.contactInfo,
      data.availabilityData
    );
  }

  toFirestore() {
    return {
      resortId: this.resortId,
      name: this.name,
      location: this.location,
      description: this.description,
      amenities: this.amenities,
      capacityPerUnit: this.capacityPerUnit,
      numberOfUnits: this.numberOfUnits,
      pricePerNightPerUnit: this.pricePerNightPerUnit,
      images: this.images,
      contactInfo: this.contactInfo,
      availabilityData: this.availabilityData,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

module.exports = Resort;
