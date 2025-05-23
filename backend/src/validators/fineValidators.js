const Joi = require('joi');
const { FINE_STATUS } = require('../config/constants');

const createFineSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'User ID is required',
  }),
  reason: Joi.string().min(2).max(200).required().messages({
    'string.min': 'Reason must be at least 2 characters',
    'string.max': 'Reason cannot exceed 200 characters',
    'any.required': 'Reason is required',
  }),
  amount: Joi.number().positive().precision(2).required().messages({
    'number.base': 'Amount must be a number',
    'number.positive': 'Amount must be a positive number',
    'number.precision': 'Amount can have at most 2 decimal places',
    'any.required': 'Amount is required',
  }),
});

const adminUpdateFineStatusSchema = Joi.object({
  status: Joi.string().valid(
    FINE_STATUS.PAYMENT_PENDING,
    FINE_STATUS.PAY_BY_CUSTOMER,
    FINE_STATUS.PAYMENT_CONFIRMED,
    FINE_STATUS.PAYMENT_DECLINED
  ).required().messages({
    'any.only': `Status must be one of [${Object.values(FINE_STATUS).join(', ')}]`,
    'any.required': 'Status is required',
  }),
});

module.exports = {
  createFineSchema,
  adminUpdateFineStatusSchema,
};