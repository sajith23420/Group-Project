const Joi = require('joi');
const { BILL_TYPES, BILL_PAYMENT_STATUS } = require('../config/constants');

const initiateBillPaymentSchema = Joi.object({
  billType: Joi.string().valid(...Object.values(BILL_TYPES)).required().messages({
    'any.only': `Bill type must be one of [${Object.values(BILL_TYPES).join(', ')}]`,
    'any.required': 'Bill type is required',
  }),
  billReferenceNumber: Joi.string().min(1).max(100).required().messages({
    'string.min': 'Bill reference number must be at least 1 character',
    'string.max': 'Bill reference number cannot exceed 100 characters',
    'any.required': 'Bill reference number is required',
  }),
  billerName: Joi.string().min(2).max(100).required().messages({
    'string.min': 'Biller name must be at least 2 characters',
    'string.max': 'Biller name cannot exceed 100 characters',
    'any.required': 'Biller name is required',
  }),
  amount: Joi.number().positive().precision(2).required().messages({
    'number.base': 'Amount must be a number',
    'number.positive': 'Amount must be a positive number',
    'number.precision': 'Amount can have at most 2 decimal places',
    'any.required': 'Amount is required',
  }),
});

const confirmBillPaymentSchema = Joi.object({
  transactionId: Joi.string().required().messages({
    'any.required': 'Transaction ID is required',
  }),
  paymentGatewayResponse: Joi.object().required().messages({
    'any.required': 'Payment gateway response is required',
  }),
  status: Joi.string().valid(BILL_PAYMENT_STATUS.COMPLETED, BILL_PAYMENT_STATUS.FAILED).required().messages({
    'any.only': `Status must be one of [${BILL_PAYMENT_STATUS.COMPLETED}, ${BILL_PAYMENT_STATUS.FAILED}]`,
    'any.required': 'Status is required',
  }),
});

module.exports = {
  initiateBillPaymentSchema,
  confirmBillPaymentSchema,
};
