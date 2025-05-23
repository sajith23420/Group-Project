class Officer {
  constructor(
    officerId,
    name,
    designation,
    assignedPostOfficeId,
    contactNumber,
    email,
    photoUrl
  ) {
    this.officerId = officerId;
    this.name = name;
    this.designation = designation;
    this.assignedPostOfficeId = assignedPostOfficeId;
    this.contactNumber = contactNumber || null;
    this.email = email || null;
    this.photoUrl = photoUrl || null;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new Officer(
      doc.id,
      data.name,
      data.designation,
      data.assignedPostOfficeId,
      data.contactNumber,
      data.email,
      data.photoUrl
    );
  }

  toFirestore() {
    return {
      officerId: this.officerId,
      name: this.name,
      designation: this.designation,
      assignedPostOfficeId: this.assignedPostOfficeId,
      contactNumber: this.contactNumber,
      email: this.email,
      photoUrl: this.photoUrl,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

module.exports = Officer;
