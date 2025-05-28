const { MONEY_ORDER_STATUS } = require('../config/constants');

class MoneyOrder {
  constructor(
    moneyOrderId,
    senderUserId,
    recipientName,
    recipientAddress,
    recipientContact,
    amount,
    serviceCharge,
    transactionId,
    paymentGatewayResponse,
    status = MONEY_ORDER_STATUS.PENDING_PAYMENT,
    notes
  ) {
    this.moneyOrderId = moneyOrderId;
    this.senderUserId = senderUserId;
    this.recipientName = recipientName;
    this.recipientAddress = recipientAddress;
    this.recipientContact = recipientContact;
    this.amount = Number(amount);
    this.serviceCharge = Number(serviceCharge);
    this.totalAmount = this.amount + this.serviceCharge;
    this.transactionId = transactionId || null;
    this.paymentGatewayResponse = paymentGatewayResponse || null;
    this.status = status;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
    this.notes = notes || null;
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new MoneyOrder(
      doc.id,
      data.senderUserId,
      data.recipientName,
      data.recipientAddress,
      data.recipientContact,
      data.amount,
      data.serviceCharge,
      data.transactionId,
      data.paymentGatewayResponse,
      data.status,
      data.notes
    );
  }

  toFirestore() {
    return {
      moneyOrderId: this.moneyOrderId,
      senderUserId: this.senderUserId,
      recipientName: this.recipientName,
      recipientAddress: this.recipientAddress,
      recipientContact: this.recipientContact,
      amount: this.amount,
      serviceCharge: this.serviceCharge,
      totalAmount: this.totalAmount,
      transactionId: this.transactionId,
      paymentGatewayResponse: this.paymentGatewayResponse,
      status: this.status,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      notes: this.notes,
    };
  }
}

module.exports = MoneyOrder;
