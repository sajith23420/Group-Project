const { BILL_PAYMENT_STATUS } = require('../config/constants');

class BillPayment {
  constructor(
    billPaymentId,
    userId,
    billType,
    billReferenceNumber,
    billerName,
    amount,
    transactionId,
    paymentGatewayResponse,
    status = BILL_PAYMENT_STATUS.PENDING_PAYMENT
  ) {
    this.billPaymentId = billPaymentId;
    this.userId = userId;
    this.billType = billType;
    this.billReferenceNumber = billReferenceNumber;
    this.billerName = billerName;
    this.amount = Number(amount);
    this.transactionId = transactionId || null;
    this.paymentGatewayResponse = paymentGatewayResponse || null;
    this.status = status;
    this.paymentDate = null;
    this.createdAt = new Date().toISOString();
  }

  static fromFirestore(doc) {
    const data = doc.data();
    const billPayment = new BillPayment(
      doc.id,
      data.userId,
      data.billType,
      data.billReferenceNumber,
      data.billerName,
      data.amount,
      data.transactionId,
      data.paymentGatewayResponse,
      data.status
    );
    billPayment.paymentDate = data.paymentDate || null;
    billPayment.createdAt = data.createdAt;
    return billPayment;
  }

  toFirestore() {
    const firestoreObject = {
      billPaymentId: this.billPaymentId,
      userId: this.userId,
      billType: this.billType,
      billReferenceNumber: this.billReferenceNumber,
      billerName: this.billerName,
      amount: this.amount,
      transactionId: this.transactionId,
      paymentGatewayResponse: this.paymentGatewayResponse,
      status: this.status,
      createdAt: this.createdAt,
    };
    if (this.paymentDate) {
      firestoreObject.paymentDate = this.paymentDate;
    }
    return firestoreObject;
  }
}

module.exports = BillPayment;
