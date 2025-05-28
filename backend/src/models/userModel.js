class User {
  constructor(uid, email, displayName, phoneNumber, role, profilePictureUrl = null, paymentHistoryRefs = [], address = null) {
    this.uid = uid;
    this.email = email;
    this.displayName = displayName;
    this.phoneNumber = phoneNumber || null;
    this.role = role;
    this.profilePictureUrl = profilePictureUrl;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
    this.paymentHistoryRefs = paymentHistoryRefs;
    this.address = address || null;
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new User(
      doc.id,
      data.email,
      data.displayName,
      data.phoneNumber,
      data.role,
      data.profilePictureUrl,
      data.paymentHistoryRefs,
      data.address
    );
  }

  toFirestore() {
    return {
      uid: this.uid,
      email: this.email,
      displayName: this.displayName,
      phoneNumber: this.phoneNumber,
      role: this.role,
      profilePictureUrl: this.profilePictureUrl,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      paymentHistoryRefs: this.paymentHistoryRefs,
      address: this.address,
    };
  }
}

module.exports = User;
