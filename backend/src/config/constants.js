const USER_ROLES = {
  USER: 'user',
  ADMIN: 'admin',
};

const MONEY_ORDER_STATUS = {
  PENDING_PAYMENT: 'pending_payment',
  PROCESSING: 'processing',
  COMPLETED: 'completed',
  FAILED: 'failed',
  CANCELLED: 'cancelled',
};

const BILL_PAYMENT_STATUS = {
  PENDING_PAYMENT: 'pending_payment',
  COMPLETED: 'completed',
  FAILED: 'failed',
};

const BILL_TYPES = {
  OSF: 'OSF',
  EXAM_FEE: 'ExamFee',
};

const BOOKING_STATUS = {
  PENDING_PAYMENT: 'pending_payment',
  CONFIRMED: 'confirmed',
  CANCELLED_BY_USER: 'cancelled_by_user',
  CANCELLED_BY_ADMIN: 'cancelled_by_admin',
  COMPLETED: 'completed',
};

const FEEDBACK_STATUS = {
  NEW: 'new',
  UNDER_REVIEW: 'under_review',
  RESOLVED: 'resolved',
  CLOSED: 'closed',
};

const POST_OFFICE_SERVICES = {
  MAIL: 'Mail',
  MONEY_ORDER: 'Money Order',
  BILL_PAYMENT: 'Bill Payment',
  RESORT_BOOKING: 'Resort Booking',
};

const FINE_STATUS = {
  PAYMENT_PENDING: 'payment_pending',      // Default when admin adds
  PAY_BY_CUSTOMER: 'pay_by_customer',      // Customer initiates payment
  PAYMENT_CONFIRMED: 'payment_confirmed',  // Admin confirms payment
  PAYMENT_DECLINED: 'payment_declined',    // Admin declines payment
};

const PARCEL_STATUS = {
  PENDING: 'pending',                      // Parcel created, not yet sent
  SENT: 'sent',                            // Parcel sent by post office
  IN_DELIVERY: 'in_delivery',              // Parcel is being delivered
  RECEIVED_AT_DESTINATION: 'received_at_destination', // Arrived at destination post office
  RECEIVED_BY_RECEIVER: 'received_by_receiver',       // Received by recipient
};

module.exports = {
  USER_ROLES,
  MONEY_ORDER_STATUS,
  BILL_PAYMENT_STATUS,
  BILL_TYPES,
  BOOKING_STATUS,
  FEEDBACK_STATUS,
  POST_OFFICE_SERVICES,
  FINE_STATUS,
  PARCEL_STATUS,
};
