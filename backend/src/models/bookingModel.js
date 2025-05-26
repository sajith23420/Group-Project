const { BOOKING_STATUS } = require('../config/constants');

class Booking {
  constructor(
    bookingId,
    userId,
    resortId,
    checkInDate,
    checkOutDate,
    numberOfGuests,
    numberOfUnitsBooked,
    totalAmount,
    transactionId,
    paymentGatewayResponse,
    status = BOOKING_STATUS.PENDING_PAYMENT,
    specialRequests
  ) {
    this.bookingId = bookingId;
    this.userId = userId;
    this.resortId = resortId;
    this.checkInDate = checkInDate;
    this.checkOutDate = checkOutDate;
    this.numberOfGuests = Number(numberOfGuests);
    this.numberOfUnitsBooked = Number(numberOfUnitsBooked) || 1;
    this.totalAmount = Number(totalAmount);
    this.transactionId = transactionId || null;
    this.paymentGatewayResponse = paymentGatewayResponse || null;
    this.status = status;
    this.bookedAt = new Date().toISOString();
    this.specialRequests = specialRequests || null;
    this.updatedAt = new Date().toISOString();
  }

  static fromFirestore(doc) {
    const data = doc.data();
    const booking = new Booking(
      doc.id,
      data.userId,
      data.resortId,
      data.checkInDate,
      data.checkOutDate,
      data.numberOfGuests,
      data.numberOfUnitsBooked,
      data.totalAmount,
      data.transactionId,
      data.paymentGatewayResponse,
      data.status,
      data.specialRequests
    );
    booking.bookedAt = data.bookedAt;
    booking.updatedAt = data.updatedAt;
    return booking;
  }

  toFirestore() {
    return {
      bookingId: this.bookingId,
      userId: this.userId,
      resortId: this.resortId,
      checkInDate: this.checkInDate,
      checkOutDate: this.checkOutDate,
      numberOfGuests: this.numberOfGuests,
      numberOfUnitsBooked: this.numberOfUnitsBooked,
      totalAmount: this.totalAmount,
      transactionId: this.transactionId,
      paymentGatewayResponse: this.paymentGatewayResponse,
      status: this.status,
      bookedAt: this.bookedAt,
      specialRequests: this.specialRequests,
      updatedAt: this.updatedAt,
    };
  }
}

module.exports = Booking;
