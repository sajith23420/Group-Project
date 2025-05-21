const { FINE_STATUS } = require('../config/constants');

class Fine {
  constructor(
    fineId,
    userId,
    reason,
    amount,
    status = FINE_STATUS.PAYMENT_PENDING,
    createdBy
  ) {
    this.fineId = fineId;
    this.userId = userId;
    this.reason = reason;
    this.amount = Number(amount);
    this.status = status;
    this.createdBy = createdBy; // admin who created the fine
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  static fromFirestore(doc) {
    const data = doc.data();
    const fine = new Fine(
      doc.id,
      data.userId,
      data.reason,
      data.amount,
      data.status,
      data.createdBy
    );
    fine.createdAt = data.createdAt;
    fine.updatedAt = data.updatedAt;
    return fine;
  }

  toFirestore() {
    return {
      fineId: this.fineId,
      userId: this.userId,
      reason: this.reason,
      amount: this.amount,
      status: this.status,
      createdBy: this.createdBy,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

module.exports = Fine;