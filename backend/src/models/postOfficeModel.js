class PostOffice {
  constructor(
    postOfficeId,
    name,
    postalCode,
    address,
    contactNumber,
    postmasterName,
    servicesOffered,
    operatingHours,
    latitude,
    longitude,
    subPostOfficeIds = []
  ) {
    this.postOfficeId = postOfficeId;
    this.name = name;
    this.postalCode = postalCode;
    this.address = address;
    this.contactNumber = contactNumber;
    this.postmasterName = postmasterName;
    this.subPostOfficeIds = subPostOfficeIds;
    this.servicesOffered = servicesOffered;
    this.operatingHours = operatingHours;
    this.latitude = latitude;
    this.longitude = longitude;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new PostOffice(
      doc.id,
      data.name,
      data.postalCode,
      data.address,
      data.contactNumber,
      data.postmasterName,
      data.servicesOffered,
      data.operatingHours,
      data.latitude,
      data.longitude,
      data.subPostOfficeIds
    );
  }

  toFirestore() {
    return {
      postOfficeId: this.postOfficeId,
      name: this.name,
      postalCode: this.postalCode,
      address: this.address,
      contactNumber: this.contactNumber,
      postmasterName: this.postmasterName,
      subPostOfficeIds: this.subPostOfficeIds,
      servicesOffered: this.servicesOffered,
      operatingHours: this.operatingHours,
      latitude: this.latitude,
      longitude: this.longitude,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

module.exports = PostOffice;
