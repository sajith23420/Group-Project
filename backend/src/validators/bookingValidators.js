const Joi = require('joi');
const { BOOKING_STATUS } = require('../config/constants');

const createBookingSchema = Joi.object({
  resortId: Joi.string().required().messages({
    'any.required': 'Resort ID is required',
  }),
  checkInDate: Joi.date().iso().required().messages({
    'date.base': 'Check-in date must be a valid date',
    'date.format': 'Check-in date must be in ISO format (YYYY-MM-DD)',
    'any.required': 'Check-in date is required',
  }),
  checkOutDate: Joi.date().iso().greater(Joi.ref('checkInDate')).required().messages({
    'date.base': 'Check-out date must be a valid date',
    'date.format': 'Check-out date must be in ISO format (YYYY-MM-DD)',
    'date.greater': 'Check-out date must be after check-in date',
    'any.required': 'Check-out date is required',
  }),
  numberOfGuests: Joi.number().integer().min(1).required().messages({
    'number.base': 'Number of guests must be a number',
    'number.integer': 'Number of guests must be an integer',
    'number.min': 'Number of guests must be at least 1',
    'any.required': 'Number of guests is required',
  }),
  numberOfUnitsBooked: Joi.number().integer().min(1).default(1).optional().messages({
    'number.integer': 'Number of units booked must be an integer',
    'number.min': 'Number of units booked must be at least 1',
  }),
  specialRequests: Joi.string().max(500).optional().allow(null, ''),
});

const confirmBookingPaymentSchema = Joi.object({
  transactionId: Joi.string().required().messages({
    'any.required': 'Transaction ID is required',
  }),
  paymentGatewayResponse: Joi.object().required().messages({
    'any.required': 'Payment gateway response is required',
  }),
});

const adminUpdateBookingStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(BOOKING_STATUS)).required().messages({
    'any.only': `Status must be one of [${Object.values(BOOKING_STATUS).join(', ')}]`,
    'any.required': 'Status is required',
  }),
});

module.exports = {
  createBookingSchema,
  confirmBookingPaymentSchema,
  adminUpdateBookingStatusSchema,
};
