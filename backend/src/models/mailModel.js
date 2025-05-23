const { PARCEL_STATUS } = require('../config/constants');

class Mail {
  constructor(
    mailId,
    userId,
    senderName,
    receiverName,
    receiverAddress,
    weight,
    status = PARCEL_STATUS.PENDING,
    createdBy
  ) {
    this.mailId = mailId;
    this.userId = userId;
    this.senderName = senderName;
    this.receiverName = receiverName;
    this.receiverAddress = receiverAddress;
    this.weight = Number(weight);
    this.status = status;
    this.createdBy = createdBy; // admin who created the parcel
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  static fromFirestore(doc) {
    const data = doc.data();
    const mail = new Mail(
      doc.id,
      data.userId,
      data.senderName,
      data.receiverName,
      data.receiverAddress,
      data.weight,
      data.status,
      data.createdBy
    );
    mail.createdAt = data.createdAt;
    mail.updatedAt = data.updatedAt;
    return mail;
  }

  toFirestore() {
    return {
      mailId: this.mailId,
      userId: this.userId,
      senderName: this.senderName,
      receiverName: this.receiverName,
      receiverAddress: this.receiverAddress,
      weight: this.weight,
      status: this.status,
      createdBy: this.createdBy,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

module.exports = Mail;