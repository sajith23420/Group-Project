const Joi = require('joi');
const { MONEY_ORDER_STATUS } = require('../config/constants');

const initiateMoneyOrderSchema = Joi.object({
  recipientName: Joi.string().min(3).max(100).required().messages({
    'string.min': 'Recipient name must be at least 3 characters',
    'string.max': 'Recipient name cannot exceed 100 characters',
    'any.required': 'Recipient name is required',
  }),
  recipientAddress: Joi.string().min(5).max(255).required().messages({
    'string.min': 'Recipient address must be at least 5 characters',
    'string.max': 'Recipient address cannot exceed 255 characters',
    'any.required': 'Recipient address is required',
  }),
  recipientContact: Joi.string().pattern(/^[0-9]{10,15}$/).required().messages({
    'string.pattern.base': 'Recipient contact must be between 10 to 15 digits',
    'any.required': 'Recipient contact is required',
  }),
  amount: Joi.number().positive().precision(2).required().messages({
    'number.base': 'Amount must be a number',
    'number.positive': 'Amount must be a positive number',
    'number.precision': 'Amount can have at most 2 decimal places',
    'any.required': 'Amount is required',
  }),
  notes: Joi.string().max(500).optional().allow(null, '').messages({
    'string.max': 'Notes cannot exceed 500 characters',
  }),
});

const confirmMoneyOrderPaymentSchema = Joi.object({
  transactionId: Joi.string().required().messages({
    'any.required': 'Transaction ID is required',
  }),
  paymentGatewayResponse: Joi.object().required().messages({
    'any.required': 'Payment gateway response is required',
  }),
  status: Joi.string().valid(MONEY_ORDER_STATUS.PROCESSING, MONEY_ORDER_STATUS.COMPLETED, MONEY_ORDER_STATUS.FAILED).required().messages({
    'any.only': `Status must be one of [${MONEY_ORDER_STATUS.PROCESSING}, ${MONEY_ORDER_STATUS.COMPLETED}, ${MONEY_ORDER_STATUS.FAILED}]`,
    'any.required': 'Status is required',
  }),
});

const adminUpdateMoneyOrderStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(MONEY_ORDER_STATUS)).required().messages({
    'any.only': `Status must be one of [${Object.values(MONEY_ORDER_STATUS).join(', ')}]`,
    'any.required': 'Status is required',
  }),
});

module.exports = {
  initiateMoneyOrderSchema,
  confirmMoneyOrderPaymentSchema,
  adminUpdateMoneyOrderStatusSchema,
};
